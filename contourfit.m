function varargout = contourfit(I1, I2, D, iid, varargin)
%CONTOURFIT Generates surface fits to grid data.
%   [FO, G , h, i1, i2, d] = CONTOURFIT(I1, I2, D, 'iid') returns a fit
%   object, goodness-of-fit measures, figure with contour plot, independent
%   grid vectors, and a corresponding dependent grid matrix. The 'iid'
%   string specifies the axes on  which to plot independent, independent,
%   and dependent variables I1, I2, and D. 
%   
%   Options for 'iid' string are 'xyz', 'xzy', or 'yzx'
% 
%   CONTOURFIT(___, n) returns n-element vectors and nxn grid matrix
%   (n defaults to 99)
%
%   CONTOURFIT(___, ft) uses the argument ft for surface <a href="matlab:doc fittype">fittype</a>
%   (ft defaults to 'thinplateinterp')
%
%   CONTOURFIT(___, x, y, C) plots fit on image array C in locations
%   specified by two-element vectors x and y. See <a href="matlab:doc
%   imagesc">imagesc</a> for syntax details.
%   
%   CONTOURFIT(___, H) plots fit on image array C when elements x, y,
%   and C exist in structure H. See <a href="matlab:doc imagesc">imagesc</a> for syntax details.
%
%   CONTOURFIT(___, n, ft)
%
%   CONTOURFIT(___, n, x, y, C)
%
%   CONTOURFIT(___, n, H)
%
%   CONTOURFIT(___, n, ft, x, y, C)
%
%   CONTOURFIT(___, n, ft, H)
%
%   CONTOURFIT uses <a href="matlab:doc curvefit/fit">fit</a> and <a href="matlab:doc curvefit/fittype">fittype</a> functions from the Curve Fitting
%   Toolbox.
%
p = inputParser;
p.StructExpand = true;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
validFittype = @(x) ischar(x) || isa(x, 'function_handle') || ...
    iscellstr(x(1)) || isa(x{1}, 'function_handle');
addRequired(p, 'iid', @(x) any(validatestring(x, {'xyz', 'xzy', 'yzx'})));
switch nargin - 4
    case 1
        if validScalarPosNum(varargin{1})
            addOptional(p, 'n', 99, validScalarPosNum)
        elseif isa(varargin{1}, 'struct')
            addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
            addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
            addOptional(p, 'C', false)
        else
            addOptional(p, 'ft', 'thinplateinterp', validFittype)
        end
    case 2
        addOptional(p, 'n', 99, validScalarPosNum)
        if isa(varargin{2}, 'struct')
            addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
            addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
            addOptional(p, 'C', false)
        else
            addOptional(p, 'ft', 'thinplateinterp', validFittype)
        end
    case 3
        if validScalarPosNum(varargin{1}) && isa(varargin{3}, 'struct')
            addOptional(p, 'n', 99, validScalarPosNum)
            addOptional(p, 'ft', 'thinplateinterp', validFittype)
            addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
            addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
            addOptional(p, 'C', false)
        else
            addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
            addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
            addOptional(p, 'C', false)
        end
    case 4
        addOptional(p, 'n', 99, validScalarPosNum)
        addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'C', false)
    case 5
        addOptional(p, 'n', 99, validScalarPosNum)
        addOptional(p, 'ft', 'thinplateinterp', validFittype)
        addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'C', false)
end
parse(p, iid, varargin{:})
iid = p.Results.iid;
if isfield(p.Results, 'n')
    n = p.Results.n;
else
    n = 99; % optional does not automagically appear in parser struct
end
if isfield(p.Results, 'ft')
    ft = fittype(p.Results.ft);
    if isa(ft, 'cell')
        ft = ft{:};
    end
else
    ft = fittype('thinplateinterp'); % optional does not automagically appear in parser struct
end
[xData, yData, zData] = prepareSurfaceData(I1, I2, D);
[FO, G] = fit([xData, yData], zData, ft, 'Normalize', 'off');
h = figure;
hold on; grid on;
% set(gcf, 'Name', name, 'Color', 'w');
set(gcf, 'Name', [sprintf('%s = ', inputname(3)), '\itf\rm', ...
    sprintf('(%s, %s)', inputname(1), inputname(2))], ...
	'Color', 'white'); 
title(get(gcf, 'Name'));
% h = plot(fitresult, [xData, yData], zData);
i1_span = max(I1(:)) - min(I1(:));
i1 = linspace(min(I1(:)) - .2 * i1_span, max(I1(:))+.2 * i1_span, n);
i2_span = max(I2(:)) - min(I2(:));
i2 = linspace(min(I2(:)) - .2 * i2_span, max(I2(:))+.2 * i2_span, n);
if isfield(p.Results, 'C')
    imagesc(p.Results.x, p.Results.y, flipud(im2uint8(p.Results.C)), 'AlphaData', .5);
    % colormap(gca, gray(256));
    set(gca, 'YDir', 'normal', 'Visible', 'on', ...
        'XLim', p.Results.x, 'YLim', p.Results.y);
    s = size(p.Results.C);
    pbaspect([s(2), s(1), 1])
end
switch lower(iid)
    case 'xyz'
        [x, y] = meshgrid(i1, i2);
        z = FO(x, y);
        d = z;
        set(gcf, 'Colormap', lines(length(unique(D))))
        [hc, hh] = contour(x, y, z, unique(D));
        for i = 1:size(D, 1)
            hl(1) = line(I1(i, :), I2(i, :));
            hl(2) = line(I1(i, :), I2(i, :));
        end
        % axis([min(I1(:)), max(I1(:)), min(I2(:)), max(I2(:))])
    case 'xzy'
        [x, z] = meshgrid(i1, i2);
        y = FO(x, z);
        d = y;
        set(gcf, 'Colormap', lines(length(unique(I2))))
        [hc, hh] = contour(x, y, z, unique(I2));
        for i = 1:size(D, 1)
            hl(1) = line(I1(i, :), D(i, :));
            hl(2) = line(I1(i, :), D(i, :));
        end
        % axis([min(I1(:)), max(I1(:)), min(D(:)), max(D(:))])
    case 'yzx'
        [y, z] = meshgrid(i1, i2);
        x = FO(y, z);
        d = x;
        set(gcf, 'Colormap', lines(length(unique(I2))))
        [hc, hh] = contour(x, y, z, unique(I2));
        for i = 1:size(D, 1)
            hl(1) = line(D(i, :), I1(i, :));
            hl(2) = line(D(i, :), I1(i, :));
        end
        % axis([min(D(:)), max(D(:)), min(I1(:)), max(I1(:))])
end
set(hl, 'LineStyle', 'none', 'MarkerSize', 9)
set(hl(1), 'Marker', '+', 'Color', 'c')
set(hl(2), 'Marker', 'x', 'Color', 'm')
set(hh, 'LineWidth', 1.5)
% When contour is multicolor:
cmap=get(gcf, 'colormap');
set(findobj(gca, 'Type', 'patch', 'UserData', 2), 'EdgeColor', cmap)
% clabel(hc, hh, 'Color', 'b', 'BackgroundColor', 'none')
% When contour is one color:
% clabel(hc, hh, 'Color', get(hh, 'Color'), 'BackgroundColor', 'none')
varargout = {FO, G, h, i1, i2, d};

end