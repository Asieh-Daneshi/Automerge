function [dist]=myDist(x,y)
%--------------------------------------------------------------------------
% this function finds the Euclidean distance between two points (x and y),
% similar to "pdist2", but it is much fatser than "pdist2" 
% Asieh Daneshi July. 2020
%--------------------------------------------------------------------------
dist=sqrt(sum((x-y).^2));