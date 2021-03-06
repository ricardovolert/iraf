include <pkg/cq.h>

# T_ACQFTEXT -- Procedure to use the catalog access API routines to make
# an astrometry text file look like the results of a database query.
# There are two cases: 1) the astrometry file has a  simple header record
# generated by an astrometry package routine and 2) the calling program
# get this information from another source and set it.

procedure t_acqftest()

double	dval1, dval2
real	rval1, rval2
long	lval1, lval2
int	ival1, ival2
short	sval1, sval2

pointer	cq, res
int	i, catno, nqpars, fd, nlines, nfields, nres, foffset, fsize, ftype
int	recptr, nchars
char	textfile[SZ_FNAME], record[SZ_FNAME], database[SZ_FNAME]
char	catalog[SZ_FNAME], hdrtext[SZ_LINE], str[SZ_FNAME]
char	qpname[CQ_SZ_QPNAME], qpunits[CQ_SZ_QPUNITS], qpformats[CQ_SZ_QPFMTS]
char	ra[SZ_FNAME], dec[SZ_FNAME]	

pointer	cq_map(), cq_fquery()
int	cq_setcat(), cq_stati(), cq_nqpars(), open(), at_gcathdr()
int	cq_rstati(), cq_finfon(), cq_finfo(), cq_fname()
int	cq_foffset(), cq_ftype(), cq_fsize(), cq_grecord(), cq_gnrecord()
int	cq_gvali(), at_pcathdr(), cq_hinfon(), cq_hinfo()
int	cq_gvald(), cq_gvalr(), cq_gvall(), cq_gvals(), cq_gvalc()

begin
	# Get the parameters.
	call clgstr ("textfile", textfile, SZ_FNAME)
	call clgstr ("record", record, SZ_FNAME)
	call clgstr ("database", database, SZ_FNAME)

	# Map the database.
	cq = cq_map (database, READ_ONLY)

	# Set the current catalog by name. In this case the catalog record
	# is the dummy record "text".
	catno = cq_setcat (cq, record)
	call cq_stats (cq, CQCATNAME, catalog, SZ_LINE)
	call printf ("\nCurrent catalog: %s  index: %d\n")
	    call pargstr (catalog)
	    call pargi (cq_stati (cq, CQCATNO))
	call flush (STDOUT)

	# Get the number of query parameters. This should be zero in this
	# case.
	nqpars = cq_nqpars (cq)
	call printf ("nqpars = %d\n")
	    call pargi (nqpars)

	# Read the catalog header.
	fd = open (textfile, READ_ONLY, TEXT_FILE)
	nlines = at_gcathdr (fd, hdrtext, SZ_LINE)
	call printf ("catalog header text: nlines = %d\n%s\n")
	    call pargi (nlines)
	    call pargstr (hdrtext)
	call close (fd)

	# If the catalog has no header then create one from the acatpars
	# pset.
	if (nlines <= 0) {
	    nlines = at_pcathdr ("acatpars", hdrtext, SZ_LINE)
	    call printf ("catalog header text: nlines = %d\n%s\n")
	        call pargi (nlines)
	        call pargstr (hdrtext)
	}

	# Read in the catalog and make it look like a query.
	res = cq_fquery (cq, textfile, hdrtext)
	if (res == NULL)
	    return

	# Print basic query info.
        call cq_rstats (res, CQRADDRESS, str, SZ_FNAME)
        call printf ("\nraddress: %s\n")
            call pargstr (str)
        call cq_rstats (res, CQRQUERY, str, SZ_FNAME)
        call printf ("rquery: %s\n")
            call pargstr (str)
        call cq_rstats (res, CQRQPNAMES, str, SZ_FNAME)
        call printf ("rqpnames:%s\n")
            call pargstr (str)
        call cq_rstats (res, CQRQPVALUES, str, SZ_FNAME)
        call printf ("rqpvalues:%s\n")
            call pargstr (str)

        # Get the number of keywords.
        nfields = cq_rstati (res, CQNHEADER)
        call printf ("nheader = %d\n")
            call pargi (nfields)

	# Print information for each keyword.
	do i = 1, nfields {
            if (cq_hinfon (res, i, qpname, CQ_SZ_QPNAME, record, SZ_LINE) <= 0)
                next
            call printf ("keyword: %d %s %s\n")
                call pargi (i)
                call pargstr (qpname)
                call pargstr (record)
            if (cq_hinfo (res, qpname, record, SZ_LINE) <= 0)
                next
            call printf ("keyword: %d %s %s\n")
                call pargi (i)
                call pargstr (qpname)
                call pargstr (record)
	}
	call printf ("\n")

        # Get the number of fields.
        nfields = cq_rstati (res, CQNFIELDS)
        call printf ("nfields = %d\n")
            call pargi (nfields)

        # Print the information for each field.
        do i = 1, nfields {
            if (cq_finfon (res, i, qpname, CQ_SZ_FNAME, foffset, fsize,
                ftype, qpunits, CQ_SZ_FUNITS, qpformats, CQ_SZ_FFMTS) <= 0)
                next
            call printf ("field: %d %s %d %d %d %s %s\n")
                call pargi (i)
                call pargstr (qpname)
                call pargi (foffset)
                call pargi (fsize)
                call pargi (ftype)
                call pargstr (qpunits)
                call pargstr (qpformats)
            if (cq_finfo (res, qpname, foffset, fsize, ftype, qpunits,
                CQ_SZ_FUNITS, qpformats, CQ_SZ_FFMTS) <= 0)
                next
            call printf ("field: %d %s %d %d %d %s %s\n")
                call pargi (i)
                call pargstr (qpname)
                call pargi (foffset)
                call pargi (fsize)
                call pargi (ftype)
                call pargstr (qpunits)
                call pargstr (qpformats)
            if (cq_fname (res, i, qpname, CQ_SZ_FNAME) <= 0)
                next
            foffset = cq_foffset (res, qpname)
            fsize = cq_fsize (res, qpname)
            ftype = cq_ftype (res, qpname)
            call cq_funits (res, qpname, qpunits, CQ_SZ_FUNITS)
            call cq_ffmts (res, qpname, qpformats, CQ_SZ_FFMTS)
            call printf ("field: %d %s %d %d %d %s %s\n")
                call pargi (i)
                call pargstr (qpname)
                call pargi (foffset)
                call pargi (fsize)
                call pargi (ftype)
                call pargstr (qpunits)
                call pargstr (qpformats)
        }
        call  printf ("\n")

        # Get the number of records.
        nres = cq_rstati (res, CQRNRECS)
        call printf ("nrecords = %d\n")
            call pargi (nres)

        # Loop through and print the records.
        recptr = 0
        while (recptr < nres) {
            nchars = cq_gnrecord (res, record, SZ_LINE, recptr)
            if (nchars == EOF)
                break
            call printf ("record %4d %4d %s")
                call pargi (recptr)
                call pargi (nchars)
                call pargstr (record)
        }

        # Find and print records at random.
        record[1] = EOS
        nchars = cq_grecord (res, record, SZ_LINE, 1)
        call printf ("\nrecord %4d %4d %s")
            call pargi (1)
            call pargi (nchars)
            call pargstr (record)

        record[1] = EOS
        nchars = cq_grecord (res, record, SZ_LINE, (1 + nres) / 2)
        call printf ("record %4d %4d %s")
            call pargi ((1 + nres) / 2)
            call pargi (nchars)
            call pargstr (record)

        record[1] = EOS
        nchars = cq_grecord (res, record, SZ_LINE, nres)
        call printf ("record %4d %4d %s")
            call pargi (nres)
            call pargi (nchars)
            call pargstr (record)

        # Loop through the records and decode the ra and dec fields as
        # char, double precision, real precision, and integer fields.
        call printf ("\nra dec\n")
        do i = 1, nres {
            call printf ("rec %d\n")
                call pargi (i)
            nchars = cq_gvalc (res, i, "ra", ra, SZ_FNAME)
            nchars = cq_gvalc (res, i, "dec", dec, SZ_FNAME)
            call printf ("    %s %s\n")
                call pargstr (ra)
                call pargstr (dec)
            nchars = cq_gvald (res, i, "ra", dval1)
            nchars = cq_gvald (res, i, "dec", dval2)
            call printf ("    %h %h\n")
                call pargd (dval1)
                call pargd (dval2)
            nchars = cq_gvalr (res, i, "ra", rval1)
            nchars = cq_gvalr (res, i, "dec", rval2)
            call printf ("    %h %h\n")
                call pargr (rval1)
                call pargr (rval2)
            nchars = cq_gvall (res, i, "ra", lval1)
            nchars = cq_gvall (res, i, "dec", lval2)
            call printf ("    %h %h\n")
                call pargl (lval1)
                call pargl (lval2)
            nchars = cq_gvali (res, i, "ra", ival1)
            nchars = cq_gvali (res, i, "dec", ival2)
            call printf ("    %h %h\n")
                call pargi (ival1)
                call pargi (ival2)
            nchars = cq_gvals (res, i, "ra", sval1)
            nchars = cq_gvals (res, i, "dec", sval2)
            call printf ("    %h %h\n")
                call pargs (sval1)
                call pargs (sval2)
        }


	# Close the query.
	call cq_rclose (res)

	# Unmap the database.
	call cq_unmap (cq)
end
