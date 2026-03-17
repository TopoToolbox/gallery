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

export("notebooks/matlab/introduction.mlx", ...
    "notebooks/matlab/introduction.ipynb", Run=true)

end