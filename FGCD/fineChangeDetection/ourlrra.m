function [A,E] = ourlrra(D,lambda,display)

% This routine solves the following nuclear-norm optimization problem,
% which is more general than "lrr.m"
% min |Z|_*+lambda*|E|_2,1
% s.t., X = AZ+E
% inputs:
%        X -- D*N data matrix, D is the data dimension, and N is the number
%             of data vectors.
%        A -- D*M matrix of a dictionary, M is the size of the dictionary
tol = 1e-8;
maxIter = 200;
[d n] = size(D);
m = d;
rho = 1.1;
max_mu = 1e10;
mu = 1e-6;



% atx = A'*X;
% inv_a = inv(A'*A+eye(m));
%% Initializing optimization variables
% intialize
A = zeros(m,n);
J = zeros(m,n);
E = sparse(d,n);

Y1 = zeros(d,n);
Y2 = zeros(m,n);
%% Start main loop
iter = 0;
% if display
%     disp(['initial,rank=' num2str(rank(A))]);
% end
while iter<maxIter
    iter = iter + 1;
    %update A
    temp = D-E+(Y1/mu);
    [U,sigma,V] = svd(temp,'econ');
    sigma = diag(sigma);
    svp = length(find(sigma>1/mu));
    if svp>=1
        sigma = sigma(1:svp)-1/mu;
    else
        svp = 1;
        sigma = 0;
    end
    A = U(:,1:svp)*diag(sigma)*V(:,1:svp)';
    %udpate J
    temp = E - (Y2/mu);
    J = sign(temp).*pos(abs(temp)-(lambda/mu));
%     J = inv_a*(atx-A'*E+J+(A'*Y1-Y2)/mu);
    %update E
    %1
%         tempE1 = D-A+J +(Y1+Y2)/mu;
%          E =tempE1 / 2;
    %1end
    
    %2
%     tempE1 = D-A+J +(Y1+Y2)/mu;
%     tempE2 = (2*speye(d,d));
%     E1 = cgs(tempE2, tempE1(:,1));
%     E2 = cgs(tempE2, tempE1(:,2));
%     E = [E1,E2];
    %2end
    
    %3
%     tempE1 = D-A+J +(Y1+Y2)/mu;
%     tempE2 = (2*speye(d,d));
%     E1 = symmlq(tempE2, tempE1(:,1));
%     E2 = symmlq(tempE2, tempE1(:,2));
%     E = [E1,E2];
    %3end
    %4
    tempE1 = D-A+J +(Y1+Y2)/mu;
    tempE2 = (2*speye(d,d));
    E1 = lsqr(tempE2, tempE1(:,1));
    E2 = lsqr(tempE2, tempE1(:,2));
    E = [E1,E2];
    %4end
    
    leq1 = D - A - E;
    leq2 = J - E;
    stopC = max(max(max(abs(leq1))),max(max(abs(leq2))));
    if display && (iter==1 || mod(iter,50)==0 || stopC<tol)
        disp(['iter ' num2str(iter) ',mu=' num2str(mu,'%2.1e') ...
            ',rank=' num2str(rank(A,1e-4*norm(A,2))) ',stopALM=' num2str(stopC,'%2.3e')]);
    end
    if stopC<tol 
        break;
    else
        Y1 = Y1 + mu*leq1;
        Y2 = Y2 + mu*leq2;
        mu = min(max_mu,mu*rho);
    end
end