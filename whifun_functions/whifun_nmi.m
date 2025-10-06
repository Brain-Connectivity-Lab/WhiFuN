function nmi = whifun_nmi(labels1, labels2)
% WHIFUN_NMI Calculates the Normalized Mutual Information (NMI) between two label vectors.
%
%   nmi = WHIFUN_NMI(labels1, labels2) computes the Normalized Mutual
%   Information between two vectors of cluster or classification labels. NMI
%   is a symmetry measure of similarity between two data clusterings,
%   ranging from 0 (no mutual dependence) to 1 (perfect correlation).
%
%   This function is commonly used to evaluate the quality of a clustering
%   algorithm by comparing its output (labels1) to known ground truth
%   labels (labels2), or to compare two different clustering solutions.
%
%   The calculation involves the following steps:
%   1.  **Confusion Matrix (C)**: Creates a contingency table showing the
%       overlap between the two labelings.
%   2.  **Probabilities (pi, uj)**: Calculates the marginal probabilities
%       for each set of labels.
%   3.  **Mutual Information (I)**: Computes the mutual information using
%       the formula: I = sum(P(i,j) * log2(P(i,j) / (P(i) * P(j)))).
%       A small constant (1e-10) is added to avoid issues with log2(0).
%   4.  **Entropy (Hpi, Huj)**: Computes the entropy for each set of labels.
%   5.  **Normalization**: Normalizes the mutual information by the average
%       entropy of the two labelings: NMI = 2 * I / (H(pi) + H(uj)).
%
%   Input Arguments:
%   labels1 - A vector of cluster or class labels (e.g., from a clustering algorithm).
%   labels2 - A vector of ground truth or second cluster labels. Must be the
%             same length as labels1.
%
%   Output Arguments:
%   nmi     - The Normalized Mutual Information score (scalar).
%
%   Author: Pratik Jain, qqffssxx
%   See also CONFUSIONMAT, LOG2.
%   Modified by Pratik from following code
%   qqffssxx (2025). Normalized Mutual Information (NMI) for Cluster Analysis 
%   (https://www.mathworks.com/matlabcentral/fileexchange/130784-normalized-mutual-information-nmi-for-cluster-analysis), 
%   MATLAB Central File Exchange. Retrieved September 25, 2025.

    C = confusionmat(labels1, labels2);

    N = sum(C(:));
    pi = sum(C, 2) / N;
    uj = sum(C, 1) / N;
    C(pi==0,:) = [];
    C(:,uj==0) = [];
    
    pi(pi==0) = [];
    uj(uj==0) = [];
    piuj = C / N;

    % Add a small constant to avoid log2(0)
    piuj = piuj +1e-10;
    I = sum(sum(piuj .* log2(piuj ./ (pi * uj))));
    Hpi = -sum(pi .* log2(pi + 1e-10));
    Huj = -sum(uj .* log2(uj + 1e-10));
    nmi = 2 * I / (Hpi + Huj);
end

%% liscence
%{
Copyright (c) 2023, sxjmqf
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution

* Neither the name of  nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%}