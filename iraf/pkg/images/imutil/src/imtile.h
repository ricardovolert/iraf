# Header file for the IMTILE task.

# Define the structure

define	LEN_IRSTRUCT	35

define 	IT_NCOLS	Memz[P2Z($1)]	# x length of single subraster
define	IT_NROWS	Memz[P2Z($1+1)]	# y length of a single subrasters
define	IT_NXOVERLAP	Meml[P2L($1+2)]	# x overlap between subrasters
define	IT_NYOVERLAP	Meml[P2L($1+3)]	# y overlap between subrasters
define	IT_NXSUB	Memz[P2Z($1+4)]	# number of subrasters in x dimension
define	IT_NYSUB	Memz[P2Z($1+5)]	# number of subrasters in y dimension
define	IT_NXRSUB	Meml[P2L($1+6)]	# x index of reference subraster
define	IT_NYRSUB	Meml[P2L($1+7)]	# y index of reference subraster
define	IT_XREF		Meml[P2L($1+8)]	# x offset of reference subraster
define	IT_YREF		Meml[P2L($1+9)]	# y offset of reference subraster
define	IT_CORNER	Memi[P2I($1+10)]	# starting corner for insertion
define	IT_ORDER	Memi[P2I($1+11)]	# row or column insertion
define	IT_RASTER	Memi[P2I($1+12)]	# raster order
define	IT_OVAL		Memr[P2R($1+13)]	# undefined value

define	IT_IC1		Memi[P2I($1+14)]	# input image lower column limit
define	IT_IC2		Memi[P2I($1+15)]	# input image upper column limit
define	IT_IL1		Memi[P2I($1+16)]	# input image lower line limit
define	IT_IL2		Memi[P2I($1+17)]	# input image upper line limit
define	IT_OC1		Memi[P2I($1+18)]	# output image lower column limit
define	IT_OC2		Memi[P2I($1+19)]	# output image upper column limit
define	IT_OL1		Memi[P2I($1+20)]	# output image lower line limit
define	IT_OL2		Memi[P2I($1+21)]	# output image upper line limit
define	IT_DELTAX	Memi[P2I($1+22)]	# x shifts
define	IT_DELTAY	Memi[P2I($1+23)]	# y shifts
define	IT_DELTAI	Memi[P2I($1+24)]	# intensity shifts

define	IT_XRSHIFTS	Memi[P2I($1+25)]	# x row links
define	IT_YRSHIFTS	Memi[P2I($1+26)]	# y row links
define	IT_NRSHIFTS	Memi[P2I($1+27)]	# number of row links
define	IT_XCSHIFTS	Memi[P2I($1+28)]	# x column links
define	IT_YCSHIFTS	Memi[P2I($1+29)]	# y column links
define	IT_NCSHIFTS	Memi[P2I($1+30)]	# number of column links

# Define some useful constants

define	IT_LL		1
define	IT_LR		2
define	IT_UL		3
define	IT_UR		4

define	IT_ROW		1
define	IT_COLUMN	2

define	IT_COORDS	1
define	IT_SHIFTS	2
define	IT_FILE		3

define	MAX_NRANGES	100
