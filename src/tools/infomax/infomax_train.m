function [W]=infomax_train(nhid,D,W)
% function [W]=infomax_train(nhid,D,W)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputs
% nhid - size of the hidden layer of the network noramlly set to number of
%        pixels in input image (i.e. 17x90 = 1530) but can be less
% sig - SD of noise to add to chosen direction of movement (try 0.1) for
%       starters. sig = 0 gives noise free performance
% MIKESDATA - normally contains all the data specifying the 3D model of the
%       environment needed by get View
% runName0 - contains the training data
% filename - name of file used to save figure
% W - optional input containing pretrained weights of the Infomax
% network,server to re-run a same memory
%
% outputs
% W -   trained network weights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% load the training data
% load(runName0); % x y th D runName
% mat file containing the following data
% x - [1 x number of training points] vector
% y - [1 x number of training points] vector
% th - [1 x number of training points] vector
% D - [num pixels in image x number of training points]

% if only 2 inputs initialise a new network
if nargin<3 || isempty(W)
    ninput = size(D,1); % number of pixels determines the size of the input
    W = infomax_init2(ninput,nhid);
else
    W=W';
end

D = im2double(D); % make sure we have the correct input type - uint8 images won't work

% learning rate
mu=0.001;
% this while loop just reduces the learning rate if the weights blow up
while true
    try
        W = infomax_learn2(W',D,[],mu);
        break;
    catch ex
        keyboard
        mu = mu*0.99;
    end
end
clear D


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INFOMAX FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function w = infomax_init2(V,H)
% function w = infomax_init(N)
%
% Initialises the weights of a familiarity discrimination network.
%
% Input:
%  N - size of the network
% Output:
%  w - the matrix of weights: each row corresponds to the weights of a single novelty neuron

w = randn(V,H) - 0.5;

% weight normalization to ensure mean = 0 and std = 1
w = w - repmat (mean(w,2), 1, H);
w = w ./ repmat (std(w,1,2), 1, H);

function weights = infomax_learn2(weights,patts,vars,lrate)
% Infomax "extended algorithm"
if nargin < 4
    str = 'A learning rate is required';
    id = 'LearningRule:noLrateError';
    fd_error(str, id);
end
[N, P] = size(patts);
[H,V] = size(weights);
% fd_disp('Presenting familiar patterns ...','filename');
for i=1:P
    u=weights*patts(:,i);
    y=tanh(u);
    weights = weights + lrate/N * (eye(H)-(y+u)*u') * weights;
    if any(any(isnan(weights)))
        str='Weights blew up';
        id='LearningRule:WeightBlowUpError';
        %         fd_error(str, id);
    end
end
%
% function decs = infomax_decision(weights,patts)
% % Infomax decision function, using the sum of the absolute values of
% % membrane potentials
%
% result = weights*patts;
% decs = sum(abs(result));

% function for bringing angles in to range -pi to pi
% function x=pi2pi(x)
% x=mod(x,2*pi);
% x=x-(x>pi)*2*pi;

% function n2 = dist2(x, c)
% %DIST2	Calculates squared distance between two sets of points.
% %
% %	Description
% %	D = DIST2(X, C) takes two matrices of vectors and calculates the
% %	squared Euclidean distance between them.  Both matrices must be of
% %	the same column dimension.  If X has M rows and N columns, and C has
% %	L rows and N columns, then the result has M rows and L columns.  The
% %	I, Jth entry is the  squared distance from the Ith row of X to the
% %	Jth row of C.
% %
% %	See also
% %	GMMACTIV, KMEANS, RBFFWD
% %
%
% %	Copyright (c) Ian T Nabney (1996-2001)
%
% [ndata, dimx] = size(x);
% [ncentres, dimc] = size(c);
% if dimx ~= dimc
% 	error('Data dimension does not match dimension of centres')
% end
%
% n2 = (ones(ncentres, 1) * sum((x.^2)', 1))' + ...
%   ones(ndata, 1) * sum((c.^2)',1) - ...
%   2.*(x*(c'));
%
% % Rounding errors occasionally cause negative entries in n2
% if any(any(n2<0))
%   n2(n2<0) = 0;
% end