# perfsa
perfsa is the product of several tools designed to facilitate doing math with contour plots. 
* `contourgrab.m` [![View contourgrab on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/74771-contourgrab)
* `contourfit.m` [![View contourfit on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/74772-contourfit)
* `perfsa.js`
* *Independent, independent, and dependent JS variables for a particular routine*
* *a task-specific JavaScript routine (for use in browsers)*

Requires MATLAB, Curve Fitting Toolbox, Image Processing Toolbox.

First, use `contourgrab` to fit an axis to an image... 

![Contourgrab screenshot 1](https://raw.githubusercontent.com/bnordlund/perfsa/master/contourgrab1.png)

...and to aquire data points along lines of contour.

![Contourgrab screenshot 2](https://raw.githubusercontent.com/bnordlund/perfsa/master/contourgrab2.png)

Then, use `contourfit` to generate a fit for the independent, independent, and dependent variables (IID). With a fit generated for a particular dependent variable, a contour plot is drawn to check the fit. The plot must go through the acquired points, match the background image, and match plots generated for other combinations of independent and dependent variables. 

![Contourfit screenshot](https://raw.githubusercontent.com/bnordlund/perfsa/master/contourfit.png)

Independent grid vectors and a corresponding dependent grid matrix (i.e. meshgrid) are exported as JS variables for interpolation.
Results are produced from browser inputs and bilinear interpolation of grid data (in the browser). 

```matlab
function iid2JSON(name, i1, i2, d)
% IID2JSON Appends arrays converted to JSON to a .js file.
%      IID2JSON(name, i1, i2, d) appends i1, i2, and d to output.js
filename='output.js';
fid=fopen(filename,'at');
fprintf(fid,['var ',name,'_i1 = ',double2JSON(i1),';\n']);
fprintf(fid,['var ',name,'_i2 = ',double2JSON(i2),';\n']);
fprintf(fid,['var ',name,'_d = ',double2JSON(d),';\n']);
fclose(fid);
% winopen(filename)
end
```

```matlab
subfigure = 'foo';
% Grab contour data (double-click to proceed)
[X, Y, Z, H] = contourgrab();
% Save variables to MAT-file
save([subfigure, '.mat'], 'X', 'Y', 'Z', 'H');
load(subfigure)
% Generate meshgrid
% Specify order of ind, ind, and dep variables
iid = 'xzy';
% Verify order of contourfit arguments matches 'iid'
[FO, ~ , ~, i1, i2, d] = contourfit(X, Z, Y, iid, H);
name = [subfigure, upper(iid)];
iid2JSON(name, i1, i2, d);
% Check result
FO(131, 9000)
```
