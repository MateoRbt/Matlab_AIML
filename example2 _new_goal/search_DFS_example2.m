clc;
clear;

% Define graph
graph = {
'Arad', {'Sibiu', 140; 'Zerind', 75; 'Timisoara', 118};
'Zerind', {'Arad', 75; 'Oradea', 71};
'Oradea', {'Zerind', 71; 'Sibiu', 151};
'Timisoara', {'Arad', 118; 'Lugoj', 111};
'Lugoj', {'Timisoara', 111; 'Mehadia', 70};
'Mehadia', {'Lugoj', 70; 'Drobeta', 75};
'Drobeta', {'Mehadia', 75; 'Craiova', 120};
'Craiova', {'Drobeta', 120; 'R.Vilcea', 146; 'Pitesti', 138};
'Sibiu', {'Arad', 140; 'Oradea', 151; 'R.Vilcea', 80; 'Fagaras', 99};
'R.Vilcea', {'Sibiu', 80; 'Craiova', 146; 'Pitesti', 97};
'Fagaras', {'Sibiu', 99; 'Bucharest', 211};
'Pitesti', {'R.Vilcea', 97; 'Craiova', 138; 'Bucharest', 101};
'Bucharest', {'Fagaras', 211; 'Pitesti', 101; 'Urziceni', 85; 'Giurgiu', 90};
'Giurgiu', {'Bucharest', 90};
'Urziceni', {'Bucharest',85; 'Hirsova', 98;'Vaslui', 142};
'Hirsova', {'Urziceni', 98; 'Eforie', 86};
'Eforie', {'Hirsova', 86};
'Vaslui', {'Urziceni', 142; 'Iasi', 92};
'Iasi', {'Vaslui', 92; 'Neamt', 87};
'Neamt', {'Iasi', 87}
};

% Define Start and Goal nodes
startNode = 'Arad';
goalNodes = {'Eforie','Vaslui'}; % Cell array of one or more goal(s)

% Call the function
[path, cost, stepTable] = search_with_table(graph, startNode, goalNodes);

% Display the result
disp('Step-by-Step Table:');
disp(stepTable);
disp('Solution path:');
disp(path);
disp('Cost:');
disp(cost);

% ========================================

function [path, cost, stepTable] = search_with_table(graph, startNode, goalNodes)

% Get the nodes
nodes = graph(:,1);

% Initialize stack (node, g-cost, f-cost, parent), visited array, parent array, and costs
stack = {startNode, 0, 0, 'None'};  % Stack: node, g-cost, f-cost, parent
costs = Inf(1, length(nodes));  % Costs to reach each node (initialize to infinity)
costs(strcmp(nodes, startNode)) = 0;  % Cost to reach the start node is zero
parent = cell(1, length(nodes));  % Parent array to reconstruct path
visited = false(1, length(nodes));  % Visited nodes array

% Initialize step table to track each step
stepTable = table([], {}, {}, 'VariableNames', ...
    {'Step', 'Frontier', 'SelectedNode'});

stepCount = 0; % Step counter for the table
GoalFound = false;

% Main loop
while true
    % VISUAL - Before removing the selected node, capture the state of the frontier
    frontierStr = "";
    for k = 1:size(stack, 1)
        % Display f value and parent for each node in the frontier
        if k > 1
            frontierStr = frontierStr + ", ";
        end
        frontierStr = frontierStr + stack{k, 1} + "(" + num2str(stack{k, 3}) + "," + stack{k, 4} + ")";
    end

    % Check if the current node is one of the goals
    if GoalFound
        % Calculate the final cost
        current = GoalFoundNode;
        currentIndex = strcmp(nodes, current);
        cost = costs(currentIndex);
        % Reconstruct the path
        path = {};
        while ~isempty(current)
            path = [current, path];  % Add current node to the path
            for i = 1:length(nodes)
                if strcmp(nodes{i}, current)
                    current = parent{i};  % Move to the parent
                    break;
                end
            end
        end
        return;
    elseif isempty(stack)
        path = {'NOT FOUND'};
        cost = 0;
        return;
    else
        % Get the node from the top of the stack
        current = stack{end, 1}; % Get the node from the top of the stack
        currentGCost = stack{end, 2}; % Get the corresponding g-cost
        currentFCost = stack{end, 3}; % Get the corresponding f-cost
        currentParent = stack{end, 4}; % Get the parent of the current node
        stack(end, :) = [];  % Pop the current node from the stack
    end

    if ismember(current, goalNodes)
        GoalFound = true;
        GoalFoundNode = current;
    end

    % Mark the current node as visited
    for i = 1:length(nodes)
        if strcmp(nodes{i}, current)
            visited(i) = true;
            break;
        end
    end

    % Find neighbors of the current node and their costs
    for i = 1:size(graph, 1)
        if strcmp(graph{i, 1}, current)
            neighbors = graph{i, 2};  % Get neighbors and costs
            break;
        end
    end
  
    % Explore neighbors
    for i = size(neighbors, 1):-1:1
        neighbor = neighbors{i, 1};
        edgeCost = neighbors{i, 2};
        % Check if neighbor has not been visited or if a cheaper path is found
        for j = 1:length(nodes)
            if strcmp(nodes{j}, neighbor)
                newGCost = currentGCost + edgeCost;
                newFCost = 0;  % f = g "Uniform" search
                if newGCost < costs(j)  % If the new g-cost is cheaper
                    parent{j} = current;  % Update parent
                    costs(j) = newGCost;   % Update g-cost
                        stack= [stack; {neighbor, newGCost, newFCost, current}];  % Push the neighbor onto the stack     
                end
                break;
            end
        end
    end

    % VISUAL - Update step table with current state
    stepCount = stepCount + 1;
    stepTable = [stepTable; {stepCount, frontierStr, current}];
end

end