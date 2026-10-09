function new_network = threshold_network(a,rho,thres_type)
%The function thresholds an adjacency matrix using three methods. 
%using the approach of Kujala et  al.
%(2016)  https://doi.org/10.1111/ejn.13392

% a : undirected, weighted adjacency matrix
% rho : density of the network
% new_network : thresholded, binary network

% 02/2026 AT: include many types of threshold. The function uses the Brain
% Connectivity Toolbox functions

if nargin<3
    error('Check the inputs')
else
    if ~issymmetric(a) %format the matrix 
        a = a+a';
        a(logical(eye(size(a,1))))=1;
    end
    if rho>1 || rho<0
        error('rho should be between 0 and 1')
    end
end

if strcmp(thres_type,'absolute')
    new_network = threshold_absolute(a, rho); %in this case, rho is the absolute weight magnitude
elseif strcmp(thres_type,'proportional')
    new_network = threshold_proportional(a, rho); %in this case, rho is the proportion/density to hold
elseif strcmp(thres_type,'tree')
    no_links_percent = round(nnz(a(:))*rho);
    [tree,~] = my_backbone_wu(a,0);
    
    no_links_percent = no_links_percent-nnz(triu(tree,1)); %update the number 
    % of links to take into account the links from the tree
    new_network = tree; % Initialize the new network with the tree
    
    % Get the non-zero elements and their indices from the upper triangle of
    % the adjacency matrix
    a_upper = triu(a, 1);
    [row, col, a_links] = find(a_upper); 
    
    % Create a table to hold the link information and sort from strongest to
    % weakest
    link_table = table(row, col, a_links, 'VariableNames', {'row', 'col', 'weight'});
    sorted_links = sortrows(link_table, 'weight', 'descend');
    
    % Loop through the sorted links and add them to the new network until the threshold is reached
    added_links_count = 0;
    for i = 1:height(sorted_links)
        % Get the indices of the link in the original matrix
        row = sorted_links.row(i);
        col = sorted_links.col(i);
        
        % Check if the link is already in 'tree'
        if tree(row, col) == 0 && tree(col, row) == 0
            % Add the link to the new network
            new_network(row, col) = a(row, col);
            new_network(col, row) = a(col, row); 
            
            added_links_count = added_links_count + 1;
            
            if added_links_count >= no_links_percent
                break;
            end
        end
    end
else
    error('Invalid thresholding type specified. Choose ''absolute'', ''proportional'', or ''tree''.');
end
end