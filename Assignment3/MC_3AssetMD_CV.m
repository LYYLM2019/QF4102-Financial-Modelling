% Sample Monte-Carlo simulation program for European vanilla call options
% This version we have control variate.
% call syntax: Euro_vanilla_call=MC_EurCall(S0,X,r,T,sigma,q,no_samples)
%
function MC=MC_3AssetMD_CV(S0, X, sigma, C, r, q, T, no_samples)

% S0, sigma, q are vectors
% c is 3 � 3 correlation matrix
mu1 = r-q(1)-sigma(1)^2/2;
mu2 = r-q(2)-sigma(2)^2/2;
mu3 = r-q(3)-sigma(3)^2/2;
r1 = randn(no_samples,1);  % random standard normal numbers
r2 = randn(no_samples,1);
r3 = randn(no_samples,1);
p12 = C(1,2);
p13 = C(1,3);
p23 = C(2,3);
e1 = r1;
e2 = p12 * r1 +sqrt(1-p12^2) * r2;
e3 = p13 * r1 + p23-p13*p12/(sqrt(1-p12^2)) * r2 +...
    sqrt((1+2*p23*p12*p13-p12^2-p13^2-p23^2)/(1-p12^2)) * r3;

ST1=S0(1)*exp(mu1*T+e1*sigma(1)*sqrt(T));  % terminal prices in a vector
ST2=S0(2)*exp(mu2*T+e2*sigma(2)*sqrt(T));  
ST3=S0(3)*exp(mu3*T+e3*sigma(3)*sqrt(T));  

% estimate beta parameter
FA = zeros(no_samples,1);
FB = zeros(no_samples,1);

for i = 1:no_samples
    if max(ST1(i), ST2(i), ST3(i)) > X 
        FA(i) = 1;
    end
    
    if ST1(i) > X 
        FB(i) = FB(i) + 1;
    end
    if ST2(i) > X 
        FB(i) = FB(i) + 1;
    end
    if ST3(i) > X
        FB(i) = FB(i) + 1;
    end   
end

% dicount first
FA = exp(-r*T) * FA;
FB = exp(-r*T) * FB;

% estimate beta
FA_bar = mean(FA);
FB_bar = mean(FB);

beta = (FA - FA_bar).*(Fb - FB_bar) / (Fb - FB_bar).*(Fb - FB_bar);

% find MC Value
d1 = (log(S/X)+(r-q+sigma*sigma/2)*t)/sigma/sqrt(t);
d2 = d1-sigma*sqrt(t);
FB_BS = exp(-r*T) * normcdf(d2);
V = FA - beta * (FB - FB_BS);

MC(1) = mean(V);
MC(2) = std(V);

disp(['Value ', MC(1)]);
disp(['Standard Errors ', MC(2)]);
end
