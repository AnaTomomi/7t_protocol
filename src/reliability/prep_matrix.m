function [corrmat_thres, corrmat_thres_bin] = prep_matrix(corrmat,p,thres_type)
% Prepares the adjacency matrices for further computations by
%
% 1. set the diagonal to 0
% 2. Fisher transform the correlation matrix
% 3. Set negative correlations to 0
% 4. Threshold the matrix. Default threshold is proportional and 5% density
% 5. Binarize the matrix
%
% INPUTS:
%   corrmat : Adjacency matrix
%   p : threshold value
%   thres_type : threshold type. It could be 'proportional', 'tree', or
%               'absolute'
%
% OUTPUTS:
%   corrmat_thres : weighted, thresholded matrix
%   corrmat_thres_bin : binary, thresholded matrix

assert(issymmetric(corrmat),        'corrmat must be a symmetric matrix');
assert(p<=1, 'p must be a value between 0<p<1');
assert(strcmp(thres_type,'proportional') || strcmp(thres_type,'tree') || strcmp(thres_type,'absolute'), 'thres_type can be proportional, absolute, or tree');

corrmat(logical(eye(size(corrmat)))) = 0;
corrmat = atanh(corrmat); %Fisher transform
corrmat(corrmat<0)=0; %Set negative z-values to zero 

corrmat_thres = threshold_network(corrmat,p,thres_type); %threshold
corrmat_thres_bin = corrmat_thres;
corrmat_thres_bin(corrmat_thres_bin>0)=1; %binarize the network