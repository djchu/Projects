function [ vX, mX ] = SolveLsL1ProxLs( mA, vB, lambdaFctr, numIterations )
% ----------------------------------------------------------------------------------------------- %
%[ vF ] = BayesianDft( vX, numFreqBins, varX, varN, numIterations )
% High Resolution DFT using Bayesian Estimation of the DFT coefficients.
% Input:
%   - vX                -   Input Vector.
%                           Structure: Vector (Column Vector).
%                           Type: 'Single' / 'Double'.
%                           Range: (-inf, inf).
%   - numFreqBins       -   Number of Frequency Bins.
%                           The number of Frequency Bins in the Frequency
%                           Domain.
%                           Structure: Scalar.
%                           Type: 'Single' / 'Double'.
%                           Range: {1, 2, ...}.
%   - varX              -   Variance of Signal Model.
%                           The variance of each peak in the frequency
%                           domain assuming Normal Distribution.
%                           Structure: Scalar.
%                           Type: 'Single' / 'Double'.
%                           Range: (0, inf).
%   - varN              -   Variance of Noise.
%                           The variance of the noise.
%                           Structure: Scalar.
%                           Type: 'Single' / 'Double'.
%                           Range: (0, inf).
%   - numIterations     -   Number of Iterations.
%                           Number of iterations of the algorithm.
%                           Structure: Scalar.
%                           Type: 'Single' / 'Double'.
%                           Range {1, 2, ...}.
% Output:
%   - vF                -   High Resolution DFT.
%                           High Resolution DFT generated according to the
%                           Bayesian Model.
%                           Structure: Vector (Column Vector).
%                           Type: 'Single' / 'Double'.
%                           Range: (-inf, inf).
% References
%   1.  C
% Remarks:
%   1.  T
% TODO:
%   1.  Use Levinson's Recursion to solve `vB = ((lambdaFctr * mI) + mF * mQ * mF') \ vX;`.
%   2.  Add "Stopping Condition".
% Release Notes:
%   -   1.0.000     07/11/2016
%       *   First realease version.
% ----------------------------------------------------------------------------------------------- %

hObjFun = @(vX) (0.5 * sum(((mA * vX) - vB) .^ 2)) + (lambdaFctr * sum(abs(vX)));

mAA = mA.' * mA;
vAb = mA.' * vB;
vX  = pinv(mA) * vB; %<! Dealing with "Fat Matrix"

stepSizeMinVal  = 1 / sum(mA(:) .^ 2);
stepSize        = 10 * stepSizeMinVal;

mX = zeros([size(vX, 1), numIterations]);
mX(:, 1) = vX;

for ii = 2:numIterations
    
    objVal  = hObjFun(vX);
    vXPrev  = vX;
    vG      = (mAA * vX) - vAb;
    
    vX              = ProxL1(vXPrev - (stepSize * vG), stepSize * lambdaFctr);    
    objInnovation   = objVal + (vG.' * (vX - vXPrev)) + ((1 / (2 * stepSize)) * sum((vX - vXPrev) .^ 2)) - hObjFun(vX);
    
    while((objInnovation < 0) || (hObjFun(vX) > objVal))
        
        stepSize        = stepSize * 0.75;
        vX              = ProxL1(vXPrev - (stepSize * vG), stepSize * lambdaFctr);
        objInnovation   = objVal + (vG.' * (vX - vXPrev)) + ((1 / (2 * stepSize)) * sum((vX - vXPrev) .^ 2)) - hObjFun(vX);
        
    end
    
    stepSize = stepSize / 0.75;
    stepSize = max(stepSize, (lambdaFctr * stepSizeMinVal));
    
    mX(:, ii) = vX;
    
end


end


function [ vX ] = ProxL1( vX, lambdaFactor )

% Soft Thresholding
vX = max(vX - lambdaFactor, 0) + min(vX + lambdaFactor, 0);


end
