function loadNumbers(url) {
	var script = document.createElement('script');
	script.onload = function () {
		numbers();
	};
	script.onerror = function() {
		alert(url + " not loaded.");
	};
	script.src = url;
	document.head.appendChild(script);
}

// http://stackoverflow.com/a/519157
function test_input(data) {
	data = data.replace(/^\s+|\s+$/gm,'');
	return data;
}

function indexLarger(x, a) {
	// https://blogs.msdn.microsoft.com/oldnewthing/20140526-00/?p=903
	for (var i = 1; i < a.length; i++) {
		if (a[i] > x) return i;
	}
	return i - 1;
}

function bilinearInterpolation(x1, x2, y1, y2, q11, q12, q21, q22, x, y) {
	// https://en.wikipedia.org/wiki/Bilinear_interpolation#Algorithm
	var xy1 = (x2 - x) / (x2 - x1) * q11 + (x - x1) / (x2 - x1) * q21;
	var xy2 = (x2 - x) / (x2 - x1) * q12 + (x - x1) / (x2 - x1) * q22;
	var xy = (y2 - y) / (y2 - y1) * xy1 + (y - y1) / (y2 - y1) * xy2;
	return xy;
}

// In an ideal world, data follow a strict naming convention for a particular publication:
// F (for figure) + ##_##_# (Ch_Fig_SubFig) + IndependentIndependentDependent axes + argument (i1, i2, or d)
// Naming discipline facilitates arguments for calculateIID functions

function calculateIID(i1, i2, d, x, y) {
	var i12 = indexLarger(x, i1);
	var i11 = i12 - 1;
	var i22 = indexLarger(y, i2);
	var i21 = i22 - 1;
	var x1 = i1[i11];
	var x2 = i1[i12];
	var y1 = i2[i21];
	var y2 = i2[i22];
	var q11 = d[i21][i11];
	var q12 = d[i22][i11];
	var q21 = d[i21][i12];
	var q22 = d[i22][i12];
	var z = bilinearInterpolation(x1, x2, y1, y2, q11, q12, q21, q22, x, y);
	return z;
}

function calculateID(i, d, x) {
	var i1 = indexLarger(x, i);
	var i0 = i1 - 1;
	var x0 = i[i0];
	var x1 = i[i1];
	var y0 = d[i0];
	var y1 = d[i1];
	// https://en.wikipedia.org/wiki/Linear_interpolation
	var y = y0 + (x - x0) * (y1 - y0) / (x1 - x0)
	return y;
}