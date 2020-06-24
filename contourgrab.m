function varargout = contourgrab(varargin)
%CONTOURGRAB Facilitates acquiring data from plotted contours.
%   [X, Y, Z, H] = CONTOURGRAB() overlays a contour plot image with an axis
%   and prompts the user to select data points along contour lines.
%   Selected points are returned as row vectors with image data in the
%   structure H.
%
%   CONTOURGRAB(x, y, C) uses the image array C in locations specified
%   by two-element vectors x and y. See <a href="matlab:doc imagesc">imagesc</a> for syntax details.
%
%   CONTOURGRAB(H) uses the image array C when elements x, y, and C exist
%   in structure H. See <a href="matlab:doc imagesc">imagesc</a> for syntax details. 
%
%   CONTOURGRAB(X, Y, Z, H) includes data points in row vectors X, Y, and Z.
%
%   CONTOURGRAB(X, Y, Z, x, y, C)
%
%   CONTOURGRAB uses <a href="matlab:doc imcrop">imcrop</a> and <a href="matlab:doc getpts">getpts</a> functions from the Image Processing
%   Toolbox, as well as <a href="matlab:doc curvefit/fit">fit</a> and <a href="matlab:doc curvefit/fittype">fittype</a> functions from the Curve Fitting
%   Toolbox (to "QA" the fit). 
%
p = inputParser;
p.StructExpand = true;
p.CaseSensitive = true;
fname = '';
switch nargin
    case 0
        filename = '';
        if isempty(filename)
                [fname, pathname] = uigetfile(...
                    {'*.bmp;*.jpg;*.jpeg;*.tif;*.tiff;*.gif;*.png', ...
                    'Image Files (*.bmp, *.jpg, *.jpeg, *.tif, *.tiff, *.gif, *.png)';
                    '*.bpm', 'BPM files (*.bpm)';
                    '*.jpg;*jpeg', 'JPG files (*.jpg, *.jpeg)';
                    '*.tif;*tiff', 'TIFF files (*.tif, *.tiff)';
                    '*.gif', 'GIF files (*.gif)';
                    '*.png', 'PNG files (*.png)';
                    '*.*', 'All files (*.*)'}, 'Select an image file');
                if ischar(fname)
                    filename = fullfile(pathname, fname);
                else
                    return;
                end
        end
    case 1
        addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'C', false)
    case 3
        addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'C', false)
    case 4
        addOptional(p, 'X', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'Y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'Z', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'C', false)
    case 6
        addOptional(p, 'X', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'Y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'Z', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'x', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'y', false, @(x) validateattributes(x, {'double'}, {'nonempty'}))
        addOptional(p, 'C', false)
    otherwise
        return
end
parse(p, varargin{:})
h = figure;
if isfield(p.Results, 'C')
    set(gcf, 'Name', 'contourgrab', 'Color', 'white')
    ha = gca;
    I2 = p.Results.C;
    ha_limits = [p.Results.x, p.Results.y];
else
    % Load image
    set(gcf, 'Name', 'Crop Image to Axes', 'Color', 'white')
    axes('units', 'normalized', 'position', [0 0 1 1]);
    ha_limits = {};
    validLimits = @(x) isnumeric(x) && ~all(isnan(x)) && length(x) == 4;
    I2 = imcrop(imread(filename));
    close(gcf)
    h = figure;
    set(gcf, 'Name', 'Assign Axes to Image', 'Color', 'white')
    ha = gca;
    imagesc(im2uint8(I2));
    s = size(I2);
    pbaspect([s(2), s(1), 1])
    axis off
    title(fname);
    while isempty(ha_limits) && ishandle(h)
        ha_limits = inputdlg('xmin xmax ymin ymax', ...
            'Axis Properties');
        if isempty(ha_limits)
            return
        end
        if ~validLimits(str2num(ha_limits{:}))
            dlg = helpdlg('Valid limits are four space-delimited scalars.',...
            'Axes Limits?');
            uiwait(dlg);
            ha_limits = {};
        end
    end
    ha_limits = str2num(ha_limits{:});
end
set(gcf, 'Name', 'contourgrab', 'Color', 'white')
hold on
hi = imagesc(ha_limits(1:2), ha_limits(3:4), flipud(im2uint8(I2)));
s = size(I2);
pbaspect([s(2), s(1), 1])
% Structure H mimics inputs for imagesc function
H.x = ha_limits(1:2);
H.y = ha_limits(3:4);
H.C = I2;
colormap(gca, gray(256)); % ???
set(gca, 'YDir', 'normal', 'Visible', 'on', ...
    'XLim', ha_limits(1:2), 'YLim', ha_limits(3:4)); 
% Acquire data
if isfield(p.Results, 'X') && isfield(p.Results, 'Y') && isfield(p.Results, 'Z')
    X = p.Results.X;
    Y = p.Results.Y;
    Z = p.Results.Z;
    showpoints(X, Y, Z)
else
    X = [];
    Y = [];
    Z = [];
end
z = {1};
validScalarNum = @(x) isnumeric(x) && isscalar(x) && ~isnan(x);
while ~isempty(z) && ishandle(h)
    set(hi, 'AlphaData', .5);
    z = inputdlg('Contour value', 'Contour Properties');
    hh = findobj(h, 'type', 'contour');
    delete(hh)
    if ~isempty(z) && ~validScalarNum(str2double(z{:}))
        dlg = helpdlg('Valid contour values are scalars.',...
            'Add Contour?');
        uiwait(dlg);
        z = {1};
    elseif ~isempty(z) && validScalarNum(str2double(z{:}))
        set(hi, 'AlphaData', 1);
        [x, y] = getpts(ha);
        X = [X, x'];
        Y = [Y, y'];
        Z = [Z, repmat(str2double(z{:}), size(x'))];
    end
    showpoints(X, Y, Z)
end
set(hi, 'AlphaData', 1);
varargout = {X, Y, Z, H};

    function showpoints(X, Y, Z)
    %SHOWPOINTS Plots points in row vectors X, Y, and Z.
        line(X, Y, Z, ...
            'LineStyle', 'none', 'MarkerSize', 9, 'Marker', '+', 'Color', 'c');
        line(X, Y, Z, ...
            'LineStyle', 'none', 'MarkerSize', 9, 'Marker', 'x', 'Color', 'm');
        if length(unique(Z)) > 1
            % Plot fit contours
            ft = fittype('thinplateinterp');
            [FO, ~] = fit([X', Y'], Z', ft, 'Normalize', 'on');
            n = 99;
            [x_grid, y_grid] = meshgrid(...
                linspace(ha_limits(1), ha_limits(2), n), ...
                linspace(ha_limits(3), ha_limits(4), n));
            z_grid = FO(x_grid, y_grid);
            [hc, hh] = contour(x_grid, y_grid, z_grid, unique(Z), 'Color', 'b', 'LineWidth', 1.5);
            % When contour is multicolor: 
            % cmap=get(gcf, 'colormap');
            % set(findobj(gca, 'Type', 'patch', 'UserData', 2), 'EdgeColor', cmap)
            % clabel(hc, hh, 'Color', 'b', 'BackgroundColor', 'none')
            % When contour is one color:
            clabel(hc, hh, 'Color', get(hh, 'Color'), 'BackgroundColor', 'none')
        end
    end

end
