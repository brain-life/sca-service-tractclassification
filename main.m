function [] = main()

switch getenv('ENV')
case 'IUHPC'
	disp('loading paths for IUHPC')
	addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
	addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
	addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))
	addpath(genpath('/N/u/hayashis/BigRed2/git/afq-master'))
case 'VM'
	disp('loading paths for Jetstream VM')
	addpath(genpath('/usr/local/encode'))
	addpath(genpath('/usr/local/vistasoft'))
	addpath(genpath('/usr/local/jsonlab'))
	addpath(genpath('/usr/local/afq-master'))
end

% load my own config.json
config = loadjson('config.json');

% Load an FE strcuture created by the sca-service-life
load(config.fe);

% Extract the fascicle weights from the fe structure
% Dependency "encode".
%w = feGet(fe,'fiber weights');

% Extract the fascicles
fg = feGet(fe,'fibers acpc');        

% Eliminte the fascicles with non-zero entries
% Dependency "vistasoft"
%fg = fgExtract(fg, w > 0, 'keep');

% Classify the major tracts from all the fascicles
% Dependency "AFQ" use this repository: https://github.com/francopestilli/afq
disp('running afq..........')
% [fg_classified,~,classification]= AFQ_SegmentFiberGroups(config.dt6, fg);
[fg_classified,~,classification]= AFQ_SegmentFiberGroups(config.dt6, fg, [], [], false);
invalidIndicies=find(fe.life.fit.weights==0);
classification.index(invalidIndicies)=0;
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

% Save the results to disk
save('output.mat','fg_classified','classification','-v7.3');        

% saving text file with number of fibers per tracts
tract_info = cell(length(fg_classified), 2);

for i = 1:length(fg_classified)
    tract_info{i,1} = fg_classified(i).name;
    tract_info{i,2} = length(fg_classified(i).fibers);
end

table = cell2table(table);
table.Properties.VariableNames = {'Tracts', 'FiberCount'};

writetable( table, 'output_table.txt')
    
