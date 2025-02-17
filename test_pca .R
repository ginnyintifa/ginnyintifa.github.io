

x = matrix(c(3,4,2,6,2,4,6,5,7,1,2,1,7,2, 4),nrow = 5, ncol = 3)

row_mean = apply(x, 1, mean)

x_center = sweep(x, 1, row_mean)

#####svd

xc_xc_t = x_center%*%t(x_center)
x_cov = cov(t(x))
svd_xc = svd(x_center, nu = 5)
svd_xc_xc_t = svd(xc_xc_t)

###pca

pca_x = prcomp(t(x))
pca_xc = prcomp(t(x_center))



