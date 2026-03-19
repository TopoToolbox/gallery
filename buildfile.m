function plan = buildfile

% Create a plan from task functions
plan = buildplan(localfunctions);

% Make the "archive" task the default task in the plan
plan.DefaultTasks = "docs";

plan("docs").Dependencies = "installtt3";
end

function installtt3Task(~)

tlbxs = struct2table(matlab.addons.toolbox.installedToolboxes());

if ~isempty(tlbxs) && ismember("TopoToolbox", tlbxs.Name)
    return
end

% Github information
owner = "topotoolbox";
repo  = "topotoolbox3";
url   = sprintf("https://api.github.com/repos/%s/%s/releases/latest", ...
                owner, repo);

% Read API to get the latest 
opts = weboptions("ContentType","json","Timeout",10);
json  = webread(url,opts);

archstr = computer('arch');

assets  = json.assets;
I = contains({assets.name},archstr);

directory   = tempdir;
toolboxfile = fullfile(directory,assets(I).name);
file = websave(toolboxfile,...
    assets(I).browser_download_url);

matlab.addons.toolbox.installToolbox(file);

delete(toolboxfile)

end

function docsTask(~)

notebooks = struct2table(dir("notebooks/**/*.mlx"));
disp(notebooks);
for i = 1:size(notebooks, 1)
    mlx = string(fullfile( ...
        notebooks{i, "folder"}, ...
        notebooks{i, "name"}));
    [path, name, ~] = fileparts(mlx);
    nb = fullfile(path, name+".ipynb");

    fprintf("Rendering %s as %s\n", mlx, nb)
    export(mlx, nb, Run=true, FigureFormat="png");

    % MATLAB currently (R2025b) exports embedded images in output cells
    % with the text/html mimetype. The images are embedded in <img> tags
    % with a data URL. This jq (https://jqlang.org/) filter extracts the
    % data from this URL and replaces the "text/html" object in the output
    % data with an "image/png" one. This works, but depends on how MATLAB
    % chooses to export Jupyter notebooks. Bad things will also happen if
    % any other output cells have the text/html mimetype.
    jqfilter = ['''.cells[].outputs[]?.data |= if has("text/html") then ' ...
        '{"image/png" : [."text/html"[] | ' ...
        'capture("data:image/png;base64,(?<x>[A-Za-z0-9/=+]*)\"").x]} ' ...
        'else . end'' '];
    % jq will by default print colored output, which gets stored as ANSI
    % escape codes. The -M option turns this off.
    [status, cout] = system(['jq -M ' jqfilter char(nb)]);
    if status ~= 0
        error("jq unable to recode images: [%s] %s", status, cout);
    end
    writelines(cout, nb);
end

end