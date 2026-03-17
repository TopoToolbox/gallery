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
    export(mlx, nb, Run=true);
end

end