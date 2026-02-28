#!/bin/bash

if ! which lzip &> /dev/null; then
	echo "lzip is not installed and is used to decompress the source code."
	exit
fi

if ! [[ -f /usr/lib/liblapack.so ]]; then
	echo "LAPACK is not installed. You need it to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libarpack.so ]]; then
	echo "ARPACK is not installed. You need it to compile GNU Octave."
	exit
fi

if ! [[ -f /opt/qt6/lib/libQt6Core.so ]]; then
	echo "Qt6 is not installed. You need it to compile GNU Octave with a GUI."
	exit
fi

if ! [[ -f /opt/qt6/lib/libqscintilla2_qt6.so ]]; then
	echo "QScintilla with Qt6 support is not installed. You need it to compile GNU Octave with a GUI."
fi

if ! [[ -f /usr/lib/libhdf5.so ]]; then
	echo "HDF5 is not installed. It is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libfftw3.so ]]; then
	echo "FFTW is not installed. It is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libGraphicsMagick.so ]]; then
	echo "GraphicsMagick is not installed. It is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libglpk.so ]]; then
	echo "GLPK is not installed and is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libcurl.so ]]; then
	echo "cURL is not installed. It is required to install GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libqhull.so ]]; then
	echo "QHull is not installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libGLU.so ]]; then
	echo "GLU is not installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -d /usr/share/ghostscript ]]; then
	echo "Ghostscript isn't installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libsundials_core.so ]]; then
	echo "Sundials isn't installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libgl2ps.so ]]; then
	echo "gl2ps isn't installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libsndfile.so ]]; then
	echo "libsndfile isn't installed and is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libqrupdate.so ]]; then
	echo "Qrupdate isn't installed and is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/bin/pcre2-config ]]; then
	echo "pcre2 isn't installed and is required to compile GNU Octave."
	exit
fi

if ! which gfortran &> /dev/null; then
	echo "gfortran is not found within PATH. It is required to compile GNU Octave and its dependencies like LAPACK."
	exit
fi

if ! [[ -f /usr/lib/libsuitesparse_mongoose.so ]]; then
	echo "suitesparse isn't installed and is required to comple GNU Octave."
	exit
fi

if ! which info &> /dev/null; then
	echo "texinfo isn't installed and is required to compile GNU Octave."
	exit
fi

if ! which gnuplot &> /dev/null ; then
	echo "Gnuplot isn't installed and it is required for some plotting in Octave."
fi

if ! [[ -f /usr/lib/libfltk.so ]]; then
	echo "FLTK is required by some features for GNU Octave."
fi

if ! [[ -f /usr/lib/libportaudio.so ]]; then
	echo "PortAudio isn't installed and is required for audio support in GNU Octave."
fi

if ! [[ -f /usr/include/rapidjson/prettywriter.h ]]; then
	echo "RapidJSON isn't installed and is required for JSON support in Octave."
fi

if ! [[ -d /opt/jdk/bin ]]; then
	echo "Java not found. It is required to build GNU Octave."
	exit
fi