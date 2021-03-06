### written by K. Garner, Jan 2021
### Call plotting functions for observed effect sizes and p values
# ----------------------------------------------------
# define functions
# ----------------------------------------------------
plot_dens <- function(inputs4plot) {
    # plot the density functions for select n
    # saves to a png file in the project image folder
    # kwargs
    # inputs4plot is a list containing the following
    # fields
    # -- datpath: e.g. "../data/"
    # -- task: "CC" or "AB" etc
    # -- jmax: max number of plots for loop
    # -- dv: "dens_fx" or "dens_p"
    # -- sel_n: overlay densities from which subjects?
    # -- w: width in inches
    # -- h: height in inches
    # -- xlabs: vector of labels for x axis, 1 per plot
    # -- xl: xlims
    # -- max_idx: from which element should the max y value be taken from
    #             number corresponds to idx for sub.Ns
    # -- leg_id: on which plot would you like the legend? (1, or, 2)
    # -- leg_locs: x and y coordinates for the legend
    datpath <- inputs4plot$datpath
    task <- inputs4plot$task
    jmax <- inputs4plot$jmax
    dv <- inputs4plot$dv
    sel_n <- inputs4plot$sel_n
    w <- inputs4plot$w
    h <- inputs4plot$h
    xlabs <- inputs4plot$xlabs
    xl <- inputs4plot$xl
    max_idx <- inputs4plot$max_idx
    leg_id <- inputs4plot$leg_id
    leg_locs <- inputs4plot$leg_locs
    figlabel <- inputs4plot$figlabel
    figlabelon <- inputs4plot$figlabelon

    # ----------------------------------------------------
    # load data
    # ----------------------------------------------------
    load(paste(datpath, task, "/", task, "stats.RData", sep = ""))

    for (j in 1:jmax) {
        plot(res[sel_n[1], ][[dv]][[j]],
             col = wes_palette("IsleofDogs1")[1],
             lwd = 3,
             ylim = c(0,
                      max(res[max_idx[j], ][[dv]][[j]]["y"]$y)),
             xlim = xl,
             main = " ", ylab = "density",
             xlab = xlabs[j],
             bty = "n",
             cex.lab = 1,
             cex.axis = 1)
        polygon(res[sel_n[1], ][[dv]][[j]],
                col = adjustcolor(wes_palette("IsleofDogs1")[1],
                alpha.f = 0.5))
    for (i in c(2:length(sel_n))) {
        lines(res[sel_n[i], ][[dv]][[j]],
              col = wes_palette("IsleofDogs1")[i], lwd = 2)
        polygon(res[sel_n[i], ][[dv]][[j]],
              col = adjustcolor(wes_palette("IsleofDogs1")[i],
              alpha.f = 0.5))
    }
    # if a p statistic plot, add the criteria for significance
    if (dv == "dens_p") {
        abline(v = qnorm(.05), col = "#161616",
               lty = 2, lwd = 1)
    }
    # do you want a legend, and if so where to put it?
    if (j == leg_id) {
        leg_cols <- adjustcolor(wes_palette("IsleofDogs1")[c(1:4)],
                                alpha.f = 0.5)
        legend(leg_locs[1], leg_locs[2], legend = sel_n,
               col = leg_cols, lty = 1, bty = "n", cex = 1)
    }
    # add a label if desired
    if (j == 1 & figlabelon) {
        fig_label(figlabel, cex = 2)
    }
 }
}

calc_ratios_sing_origin <- function(rat_inputs, res) {
    # calculate ratio between x_1 and y_1_to_j
    # NOTE: this is for the ratio between 95% of 
    # distribution ONLY!
    # kwargs
    # -- rat_inputs: a list comprising of the following fields
    # origin <- e.g. "313"
    # dv <- "stats_fx", "stats_p", "stats_sig"
    # sub_Ns <- names of subject groups (Ns)
    # -- res: stored results from get_statistics.R
    origin <- rat_inputs$origin
    sub_Ns <- rat_inputs$sub_Ns
    dv <- rat_inputs$dv
    # get models from which to return results
    mods <- unique(colnames(res[, dv][[origin]]))
    base <- do.call(cbind, lapply(mods,
                           function(x)
                           abs(diff(res[, dv][[origin]][, x][[3]]))))
    colnames(base) <- mods # just labeling for sanity checks
    ratios4plotting <- do.call(rbind,
                                lapply(sub_Ns,
                                function(x)
                                abs(diff(res[, dv][[x]][[3]])) / base))
    rownames(ratios4plotting) <- sub_Ns
    ratios4plotting
}

calc_kl_sing_origin <- function(rat_inputs, res) {
    #### this project on hold
    # calculate ratio between x_1 and y_1_to_j
    # NOTE: this is for the ratio between 95% of 
    # distribution ONLY!
    # kwargs
    # -- rat_inputs: a list comprising of the following fields
    # origin <- e.g. "313"
    # dv <- "stats_fx", "stats_p", "stats_sig"
    # sub_Ns <- names of subject groups (Ns)
    # -- res: stored results from get_statistics.R
    origin <- rat_inputs$origin
    sub_Ns <- rat_inputs$sub_Ns
    dv <- rat_inputs$dv
    mods <- unique(unique(colnames(res[, "stats_fx"][[origin]])))
    # first calculate the approximating function for the all the densities
    d_funcs <- lapply(sub_Ns, function(j)
                              lapply(mods, function(z)
                                approxfun(x = res[, dv][[j]][[z]]$x,
                                y=res[ , dv][[j]][[z]]$y/length(res[ , dv][[j]][[z]]$y),
                                rule = 1)))
    names(d_funcs) <- sub_Ns
    # then select a series of bin widths, or xs
    xvals <- seq(0, 1, by = .001)
    # cos our effect sizes are positive correlations
    # do the same for the second distribution
    # calculate the KL divergence between the two
    kl_func <- function(pf, qf, x) {
        # -- pf: function for p - P IS THE P DIST
        # -- pq: function for q - Q IS THE APPROXIMATING DIST
        # -- x: values of x
        p <- pf(x)
        q <- qf(x)
        sum(p * log2(p / q), na.rm = T)
    }
    kl4plotting <- lapply(sub_Ns, function(x)
                                  lapply(1:length(mods),
                                         function(y)
                                         kl_func(pf = d_funcs[[origin]][[y]],
                                                 qf = d_funcs[[x]][[y]],
                                                 x = xvals)))
    kl4plotting <- do.call(rbind, kl4plotting)
    colnames(kl4plotting) <- mods
    rownames(kl4plotting) <- sub_Ns
    kl4plotting
}

calc_ratios_by_model <- function(rat_inputs, res){
    # calculate ratio between x_1_to_j and y_1_to_j
    # NOTE: this is for the ratio between 95% of
    # distribution ONLY!
    # Gives mod_a - mod_b
    # kwargs
    # -- rat_inputs: a list comprising of the following fields
    # -- dv: "stats_fx", "stats_p", "stats_sig"
    # -- sub_Ns: names of subject groups (Ns)
    # -- mods: names of the two models to compare e.g c("RM-AN", "LME")
    dv <- rat_inputs$dv
    sub_Ns <- rat_inputs$sub_Ns
    mods <- rat_inputs$mods
    r4p <- do.call(rbind,
                   lapply(sub_Ns,
                     function(x) abs(diff(res[, dv][[x]][3, mods[1]][[1]])) /
                                 abs(diff(res[, dv][[x]][3, mods[2]][[1]]))))
    colnames(r4p) <- "ratio"
    rownames(r4p) <- sub_Ns
    r4p
}

calc_meta_vs_model <- function(rat_inputs, res){
    # calculate ratio between the mu's for the sig and
    # the sim distributions
    sub_Ns <- rat_inputs$sub_Ns
    mods <- rat_inputs$mods
    dv <- rat_inputs$dv
    ratios4plotting <- do.call(rbind, lapply(sub_Ns, function(y)
                                lapply( mods, function(x)
                                res[, dv][[y]][, x][[1]] /
                                res[, "stats_fx"][[y]][, x][[1]])))
    colnames(ratios4plotting) <- mods
    rownames(ratios4plotting) <- sub_Ns
    ratios4plotting
}

plot_diagonal <- function(rat_inputs) {
    # plot x vs y, draw a dotted line on
    # the diagonal
    # kwargs
    # -- rat_inputs: a list comprising of
    # -- datpath e.g. "../data/
    # -- task: e.g. "CC"
    # -- dvs: e.g. c("stats_fx", "stats_sig")
    # -- sub_Ns <- names of subject groups (Ns)
    # -- w width of plot in inches
    # -- h: height of plot in inches
    # -- axl: axis labels - e.g. c("sim", "M-A")
    datpath <- rat_inputs$datpath
    task <- rat_inputs$task
    dvs <- rat_inputs$dvs
    sub_Ns <- rat_inputs$sub_Ns
    mods <- rat_inputs$mods
    w <- rat_inputs$w
    h <- rat_inputs$h
    axl <- rat_inputs$axl

    # ----------------------------------------------------
    # load data
    # ----------------------------------------------------
    load(paste(datpath, task, "/", task, "stats.RData", sep = ""))
    # ----------------------------------------------------
    # get xs and ys
    # ----------------------------------------------------
    xys <- do.call(rbind, lapply(sub_Ns, function(j)
                          lapply(mods, function(z)
                             data.frame(x = res[, dvs[1]][[j]][, z][[1]],
                                        y = res[, dvs[2]][[j]][, z][[1]]))))
    colnames(xys) <- mods
    rownames(xys) <- sub_Ns
    xyls <- list (do.call(rbind, xys[, mods[1]]),
                  do.call(rbind, xys[, mods[2]]))
    names(xyls) <- mods
    # ----------------------------------------------------
    # now plot the things
    # ----------------------------------------------------
    plot(x = xyls[[mods[1]]][, "x"],
         y = xyls[[mods[1]]][, "y"],
         bty = "n",
         type = "l", lty = 1,
         lwd = 2,
         col = wes_palette("IsleofDogs1")[6],
         ylim = c(0,
                  max(do.call(rbind, xyls))),
         xlim = c(0,
                  max(do.call(rbind, xyls))),
         xlab = axl[1],
         ylab = axl[2],
         cex.lab = 1,
         cex.axis = 1)
         lines(x = xyls[[mods[2]]][, "x"],
               y = xyls[[mods[2]]][, "y"],
               lwd = 2,
               col = wes_palette("IsleofDogs1")[5])
         abline(a = 0, b = 1, lty = 2, col = "grey48")
}

plot_ratios <- function(rat_inputs) {
    # plot ratio between x and y
    # kwargs
    # -- rat_inputs: a list comprising of:
    # -- datpath: e.g. "../data/
    # -- task: e.g. "CC"
    # -- dv: e.g. "dens_fx", "stats_fx", "stats_p", "stats_sig"
    # -- ratio_type: "origin" or "model" or "KL" or "stats_sig"
    # -- origin <- e.g. "313" i.e. calc ratio to this one
    # -- sub_Ns <- names of subject groups (Ns)
    # -- w width of plot in inches
    # -- h: height of plot in inches
    # -- leg_id: legend? TRUE or FALSE
    # -- leg_locs: e.g. c(5, 20)
    # -- leg_txt: e.g. c("RM-AN", "LME")
    datpath <- rat_inputs$datpath
    task <- rat_inputs$task
    dv <- rat_inputs$dv
    ratio_type <- rat_inputs$ratio_type
    ylabel <- rat_inputs$y_label
    sub_Ns <- rat_inputs$sub_Ns
    leg_id <- rat_inputs$leg_id
    leg_locs <- rat_inputs$leg_locs
    leg_txt <- rat_inputs$leg_txt
    w <- rat_inputs$w
    h <- rat_inputs$h
    ylabel <- rat_inputs$ylabel
    yl <- rat_inputs$yl
    # ----------------------------------------------------
    # load data
    # ----------------------------------------------------
    load(paste(datpath, task, "/", task, "stats.RData", sep = ""))

    # ----------------------------------------------------
    # compute ratios
    # ----------------------------------------------------
    if (ratio_type == "origin") {
        ratios <- calc_ratios_sing_origin(rat_inputs, res)
    } else if (ratio_type == "model") {
        ratios <- calc_ratios_by_model(rat_inputs, res)
    } else if (ratio_type == "KL"){
        ratios <- calc_kl_sing_origin(rat_inputs, res)
    } else if (ratio_type == "stats_sig") {
        ratios <- calc_meta_vs_model(rat_inputs, res)
    }

    # ----------------------------------------------------
    # plot ratios
    # ----------------------------------------------------

    if (ncol(ratios) > 1) {
      if (is.null(yl)){
        nuyl = c(0,
                 max(cbind(do.call(cbind, ratios[, "RM-AN"]),
                           do.call(cbind, ratios[, "LME"]))))
      } else {
        nuyl = yl
      }
        plot(x = 1:length(rownames(ratios)), y = ratios[, "RM-AN"],
             xaxt = "n",
             bty = "n",
             type = "l", lty = 1,
             lwd = 2,
             col = wes_palette("IsleofDogs1")[6],
             ylim = nuyl,
             ylab = ylabel,
             xlab = expression(italic("N")),
             cex.lab = 1,
             cex.axis = 1)
        axis(1, at = seq(1, 20, 2),
             labels = sub_Ns[seq(1, 20, 2)],
             cex.lab = 1,
             cex.axis = 1)
        lines(x = 1:length(rownames(ratios)), y = ratios[, "LME"],
              lwd = 2,
              col = wes_palette("IsleofDogs1")[5])
        # do you want a legend, and if so where to put it?
        if (leg_id) {
            leg_cols <- wes_palette("IsleofDogs1")[c(6, 5)]
            legend(leg_locs[1], leg_locs[2], legend = leg_txt,
                   col = leg_cols, lty = 1, bty = "n", cex = 1)
        }
        if (ratio_type == "stats_sig"){
            abline(h=1, lty=2, col="grey48")
        }
    } else if (ncol(ratios) == 1) {
        if (is.null(yl)){
          nuyl = c(0, 
                   max(ratios[,"ratio"])+0.5)
        } else {
          nuyl = yl
        }
        plot(x = 1:length(rownames(ratios)), y = ratios[,"ratio"], 
             xaxt = "n",
             bty = "n",
             type = "l", lty = 1,
             lwd = 2,
             col = wes_palette("IsleofDogs1")[4],
             ylim = nuyl,
             ylab = ylabel,
             xlab = expression(italic("N")),
             cex.lab = 1,
             cex.axis = 1)
        axis(1, at = seq(1, 20, 2), 
             labels = sub_Ns[seq(1, 20, 2)], 
             cex.lab = 1,
             cex.axis = 1)
    }
}