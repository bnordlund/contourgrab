# perfsa
perfsa is the product of several tools designed to facilitate doing math with contour plots. 
* `contourgrab.m`
* `contourplot.m`
* `perfsa.js`
* *Independent, independent, and dependent JS variables for a particular routine*
* *a task-specific JavaScript routine (for use in browsers)*

First, use `contourgrab` to fit an axis to an image... 

![Contourgrab screenshot 1](https://raw.githubusercontent.com/bnordlund/perfsa/master/contourgrab1.png)

...and to aquire data points along lines of contour.

![Contourgrab screenshot 2](https://raw.githubusercontent.com/bnordlund/perfsa/master/contourgrab2.png)

Then, use `contourfit` to generate a fit for the independent, independent, and dependent variables (IID). With a fit generated for a particular dependent variable, a contour plot is drawn to check the fit. The plot must go through the acquired points, match the background image, and match plots generated for other combinations of independent and dependent variables. 

![Contourfit screenshot](https://raw.githubusercontent.com/bnordlund/perfsa/master/contourfit.png)

Independent grid vectors and a corresponding dependent grid matrix (i.e. meshgrid) are exported as JS variables for interpolation.
Results are produced from browser inputs and bilinear interpolation of grid data (in the browser). 
