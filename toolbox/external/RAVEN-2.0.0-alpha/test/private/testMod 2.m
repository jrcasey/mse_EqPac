function out=testGapFill2(param)
	if nargin<1
		param.solver='gurobi';
		param.useConstraints=true;
	end

diary on

nonEssential={};
essential={};
models={};

for i=1:length(Index)
	model2=removeReactions(model,Index(i),true);
	model2=setParam(model2,'obj',{'r_4041'},1); % biomass
	model2=setParam(model2,'lb',{'r_4041'},.1);
	model2.id='yeast_reduced';
	[newConnected cannotConnect addedRxns newModel exitFlag]=fillGaps(model2,model,false,true)
	if (length(addedRxns)==0)
		nonEssential{end+1}=model.rxns{Index(i)};
	else
		essential{end+1}=model.rxns{Index(i)};
	end
	models{end+1}=newModel;
	solveLP(newModel)
end

model2=removeReactions(model,Index,true);
model2=setParam(model2,'obj',{'r_4041'},1); % biomass
model2=setParam(model2,'lb',{'r_4041'},.1);
model2.id='yeast_reduced';
[newConnected cannotConnect addedRxns newModel exitFlag]=fillGaps(model2,model,false,true)

cellfun(@(rxn) printModel(model,rxn),essential)
disp('')
cellfun(@(rxn) printModel(model,rxn),nonEssential)

diary off

% >> model.rxns(Index)

% ans = 

%     'r_0466'
%     'r_0467'
%     'r_0534'
%     'r_1068'
%     'r_1070'
%     'r_1071'
%     'r_1084'
%     'r_1166'
%     'r_1714'
%     'r_1805'