function mask = make_mask(dat, thr)
% This function generates an opacity-ramping mask with a decent plateau and
% nice ramp-on/ramp-off. Useful for presenting e.g. t-maps thresholded at
% some % of maximum.
%
% Copyright (C) Eelke Spaak, Donders Institute, Nijmegen, The Netherlands, 2019.
% 
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This code is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this code. If not, see <https://www.gnu.org/licenses/>.
%
% MODIFIED by Mark Henney May-2024 to reinstate sign of data after masking

if nargin < 2
  thr = [0.5 0.8];
end

% if data contains negatives, ensure strongly negative values are given as
% much opacity as strongly positive ones
% dat_sign = sign(dat); % Save the sign for later
dat = abs(dat);

mask = zeros(size(dat));

thr = max(dat, [], 'all') .* thr; % Modify args for max() to all dims

% everything above thr(2) is fully opaque
mask(dat > thr(2)) = 1;

% in between thr(1) and thr(2): ramp up nicely
inds = dat > thr(1) & dat < thr(2);
x = dat(inds);

% scale between 0 and 1
x = (x-min(x)) ./ (max(x)-min(x));

% make sigmoidal
beta = 2;
x = 1 ./ (1 + (x./(1-x)).^-beta);

mask(inds) = x;

% Reinstate sign
% mask = mask .* dat_sign;

end