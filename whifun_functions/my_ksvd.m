function [D,X,Cost] = my_ksvd(Y,iter,k0,s0)

% figure;
[t,N] = size(Y);
msg = 'Running k-SVD DL Algorithm ...';
xw = 0;
fw = waitbar(xw,msg);

%% Initialize Dictionaries
D = zeros(t,k0);    % Shared Dictionary
for r=1:k0
    D(:,r) = squeeze(Y(:,randperm(N,1)));
end
D = normalize(D,'norm');
D(isnan(D)) = 0;

%% Initialize Coefficient Matrix
X = zeros(k0,N);   % Shared Spatial Maps

%% DL Algorithm


% iter = 25;         % Number of maximum iteration

Cost = zeros(iter,1);

for iterat = 1:iter
    %% Sparse Coding Stage
    
%         E = Y - D*X;
        param0.L = s0;
        param0.eps = 0;
        param0.lambda = 0;
        param0.numThreads = 4;
        X = mexOMP(Y,D,param0);
        X(isnan(X)) = 0;
        
        %% Dictionary Learning Stage
        X = full(X);
        for k = 1:k0
            wk = [];
            for i = 1:N
                if X(k,i) ~= 0
                    wk = [wk,i];
                end
            end
            if isempty(wk)
                D(:,k) = squeeze(Y(:,randperm(N,1)));
                continue
            end
%             Ek = Y - (D*X - D(:,k)*X(k,:));
            DX = zeros(size(Y));
            for j = 1:k0
                if j ~= k
                    DX = DX + D(:,j)*X(j,:);
                end
            end
            Ek = Y - DX;
            
            omegak = zeros(N,length(wk));
            
            for i = 1:length(wk)
                omegak(wk(i),i) = 1;
            end
            
%             Xrk = X(k,:)*omegak;
%             Yrk = Y*omegak;
            Erk = Ek*omegak;
            
            [U,S,V] = svd(Erk);
            
            D(:,k) = U(:,1);
            Xrk = S(1,1)*V(:,1);
            
            for i = 1:length(wk)
                
                X(k,wk(i)) = Xrk(i);
            end
                                
        end
      Cost(iterat) = norm(Y-D*X,'fro')^2;  
      disp(Cost(iterat));
      xw = iterat/iter;
      waitbar(xw,fw) 
%       plot(Cost(1:iterat))
%       drawnow
end
close(fw)
end

