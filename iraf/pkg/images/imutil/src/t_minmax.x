# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<error.h>
include	<imhdr.h>
include	<imset.h>

# MINMAX -- Update the minimum and maximum pixel values of an image.  This is
# done only if the values are absent or invalid, unless the force flag is set.
# The header values are not updated when computing the min/max of an image
# section unless the force flag is set.  The values are printed on the standard
# output as they are computed, if the verbose option is selected.

procedure t_minmax()

pointer	images			# image name template
bool	force			# force recomputation of values
bool	update			# update values in image header
bool	verbose			# print values as they are computed

size_t	sz_val
long	l_val
real	r_val0, r_val1
bool	section
int	pixtype
long	vmin[IM_MAXDIM], vmax[IM_MAXDIM]
pointer	list, im, sp, pixmin, pixmax, imname, imsect
double	minval, maxval, iminval, imaxval

bool	clgetb()
long	clktime()
int	imtgetim()
pointer	imtopen(), immap()
include	<nullptr.inc>
define	tryagain_ 91

begin
	call smark (sp)
	sz_val = SZ_LINE
	call salloc (images, sz_val, TY_CHAR)
	sz_val = SZ_FNAME
	call salloc (imname, sz_val, TY_CHAR)
	call salloc (imsect, sz_val, TY_CHAR)
	call salloc (pixmin, sz_val, TY_CHAR)
	call salloc (pixmax, sz_val, TY_CHAR)

	# Get list of input images.

	call clgstr ("images", Memc[images], SZ_LINE)
	list = imtopen (Memc[images])

	# Get switches.

	force   = clgetb ("force")
	update  = clgetb ("update")
	verbose = clgetb ("verbose")

	# Process each image in the list.

	while (imtgetim (list, Memc[imname], SZ_FNAME) != EOF) {
	    call imgsection (Memc[imname], Memc[imsect], SZ_FNAME)
	    section = (Memc[imsect] != EOS)

	    call strcpy ("", Memc[pixmin], SZ_FNAME)
	    call strcpy ("", Memc[pixmax], SZ_FNAME)

	    if (update) {

		iferr (im = immap (Memc[imname], READ_WRITE, NULLPTR))
		    goto tryagain_

		pixtype = IM_PIXTYPE(im)
		if (force || (IM_LIMTIME(im) < IM_MTIME(im))) {
		    if (IM_NDIM(im) > 0) {
		        call im_vminmax (im, minval, maxval, iminval, imaxval,
		            vmin, vmax)
		        call mkoutstr (vmin, IM_NDIM(im), Memc[pixmin],
			    SZ_FNAME)
		        call mkoutstr (vmax, IM_NDIM(im), Memc[pixmax],
			    SZ_FNAME)
		    } else {
			minval = INDEFD
			maxval = INDEFD
			Memc[pixmin] = EOS
			Memc[pixmax] = EOS
		    }
		    if (! section) {
			if (IS_INDEFD(minval))
			    IM_MIN(im) = INDEFR
			else
			    IM_MIN(im) = minval
			if (IS_INDEFD(maxval))
			    IM_MAX(im) = INDEFR
			else
			    IM_MAX(im) = maxval
			l_val = 0
			IM_LIMTIME(im) = clktime (l_val)
			call imseti (im, IM_WHEADER, YES)
		    }
		} else {
		    minval = IM_MIN(im)
		    maxval = IM_MAX(im)
		}

		call imunmap (im)

	    } else {
tryagain_	iferr (im = immap (Memc[imname], READ_ONLY, NULLPTR)) {
		    call erract (EA_WARN)
		    next
		} else {
		    pixtype = IM_PIXTYPE(im)
		    if (force || IM_LIMTIME(im) < IM_MTIME(im)) {
		        if (IM_NDIM(im) > 0) {
			    call im_vminmax (im, minval, maxval, iminval,
			        imaxval, vmin, vmax)
			    call mkoutstr (vmin, IM_NDIM(im), Memc[pixmin],
			        SZ_FNAME)
			    call mkoutstr (vmax, IM_NDIM(im), Memc[pixmax],
			        SZ_FNAME)
			} else {
			    minval = INDEFD
			    maxval = INDEFD
			    Memc[pixmin] = EOS
			    Memc[pixmax] = EOS
			}
		    } else {
			minval = IM_MIN(im)
			maxval = IM_MAX(im)
		    }
		    call imunmap (im)
		}
	    }

	    # Make the section strings.

	    if (verbose) {
		if (pixtype == TY_COMPLEX) {
		    call printf ("    %s %s %z %s %z\n")
		        call pargstr (Memc[imname])
		        call pargstr (Memc[pixmin])
			r_val0 = minval
			r_val1 = iminval
		        call pargx (complex (r_val0, r_val1))
		        call pargstr (Memc[pixmax])
			r_val0 = maxval
			r_val1 = imaxval
		        call pargx (complex (r_val0, r_val1))
		    call flush (STDOUT)
		} else {
		    call printf ("    %s %s %g %s %g\n")
		        call pargstr (Memc[imname])
		        call pargstr (Memc[pixmin])
		        call pargd (minval)
		        call pargstr (Memc[pixmax])
		        call pargd (maxval)
		    call flush (STDOUT)
	        }
	    }
	}

	# Return the computed values of the last image examined as CL
	# parameters.

	call clputd ("minval", minval)
	call clputd ("maxval", maxval)
	call clputd ("iminval", iminval)
	call clputd ("imaxval", imaxval)
	call clpstr ("minpix", Memc[pixmin])
	call clpstr ("maxpix", Memc[pixmax])

	call sfree (sp)
end


# MKOUTSTR -- Encode the output string.

procedure mkoutstr (v, ndim, outstr, maxch)

long	v[ARB]		# imio v vector
int	ndim		# number of dimensions
char	outstr[ARB]	# output string
int	maxch		# maximum length of string

int	i, ip, nchars
int	ltoc()

begin
	# Encode opening brackett.
	outstr[1] = '['

	# Encode v vector values.
	ip = 2
	do i = 1, ndim {
	    nchars = ltoc (v[i], outstr[ip], maxch)
	    ip = ip + nchars
	    outstr[ip] = ','
	    ip = ip + 1
	}

	# Encode closing bracketts and EOS.
	outstr[ip-1] = ']'
	outstr[ip] = EOS
end
