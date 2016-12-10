function [] = main()

disp('loading paths')
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))
addpath(genpath('/N/u/hayashis/BigRed2/git/afq'))

% load my own config.json
config = loadjson('config.json');

% Load an FE strcuture created by the sca-service-life
load(config.fe);

% Extract the fascicle weights from the fe structure
% Dependency "encode".
w = feGet(fe,'fiber weights');

% Extract the fascicles
fg = feGet(fe,'fibers acpc');        

% Eliminte the fascicles with non-zero entries
% Dependency "vistasoft"
fg = fgExtract(fg, w > 0, 'keep');

% Classify the major tracts from all the fascicles
% Dependency "AFQ" use this repository: https://github.com/francopestilli/afq
disp('running afq..........')
[fg_classified,~,classification]= AFQ_SegmentFiberGroups(config.dt6, fg);
tracts = fg2Array(fg_classified);
clear fg

mkdir('tracts');

% Make colors for the tracts
cm = parula(length(tracts));
for it = 1:length(tracts)
   tract.name   = tracts(it).name;
   tract.color  = cm(it,:);
   tract.coords = tracts(it).fibers;
   savejson('', tract, fullfile('tracts',sprintf('%i.json',it)));
   clear tract
end

% Save the results to disl
save('output.mat','fg_classified','classification','-v7.3');        
