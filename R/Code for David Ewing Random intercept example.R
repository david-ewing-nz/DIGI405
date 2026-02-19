#Code for David Ewing.

#Linear mixed model fitting with Gibbs sampling with varying n per random effect level 

#Arguments are
#iter: no of iterations
#Z: Predictor matrix for random effects
#X: Predictor matrix for fixed effects
#y: response vector
#burnin: number of initial iterations to discard.
#taue_0: initial guess for residual precision.
#tauu_0: initial guess for random effect precision
#Kinv: inverse of K, where p(u) = N(0,\sigma^2_u K)
#a.u, b.u: hyper-parameters of gamma prior for tauu
#a.e, b.e: hyper-parameters of gamma prior for taue

normalmm.Gibbs<-function(iter,Z,X,y,burnin,taue_0,tauu_0,Kinv,a.u,b.u,a.e,b.e){
  n   <-length(y) #no. observations
  p   <-dim(X)[2] #no of fixed effect predictors.
  q   <-dim(Z)[2] #no of random effect levels
  tauu<-tauu_0
  taue<-taue_0
  beta0<-rnorm(p)
  u0   <-rnorm(q,0,sd=1/sqrt(tauu))
  
  #Building combined predictor matrix.
  W<-cbind(X,Z)
  WTW <-crossprod(W)
  WTy <-crossprod(W,y)
  library(mvtnorm)
  
  #storing results.
  par <-matrix(0,iter,p+q+2)
  #Calculating log predictive densities
  lppd<-matrix(0,iter,n)
  
  #Create modified identity matrix for joint posterior.
  I0  <-diag(p+q)
  diag(I0)[1:p]<-0
  I0[-c(1:p),-c(1:p)]  <-Kinv
  
  for(i in 1:iter){
    #Conditional posteriors.
    uKinvu <- t(u0)%*%Kinv%*%u0
    uKinvu <-as.numeric(uKinvu)
    tauu <-rgamma(1,a.u+0.5*q,b.u+0.5*uKinvu)
    #Updating component of normal posterior for beta,u
    Prec <-WTW*taue + tauu*I0
    P.var <-solve(Prec)
    P.mean<- P.var%*%WTy*taue
    betau <-rmvnorm(1,mean=P.mean,sigma=P.var)
    betau <-as.numeric(betau)
    err   <- y-W%*%betau
    taue  <-rgamma(1,a.e+0.5*n,b.e+0.5*sum(err^2))
    #storing iterations.
    par[i,]<-c(betau,tauu,taue)
    beta0  <-betau[1:p]
    u0     <-betau[p+1:q]
    lppd[i,]= dnorm(y,mean=as.numeric(W%*%betau),sd=1/sqrt(taue))
  }
  
  lppd      = lppd[-c(1:burnin),]
  lppdest   = sum(log(colMeans(lppd)))        #Estimating lppd for whole dataset.
  pwaic2    = sum(apply(log(lppd),2,FUN=var)) #Estimating effective number of parameters.
  par <-par[-c(1:burnin),]
  colnames(par)<-c(paste('beta',1:p,sep=''),paste('u',1:q,sep=''),'tau_u','tau_e')
  mresult<-list(par,lppdest,pwaic2)
  names(mresult)<-c('par','lppd','pwaic')
  return(mresult)
}

#######################################
#Running VB algorithm for a Linear mixed model.
VB.mm<-function(epsilon,iter,Kinv,Z,X,y,taue_0,tauu_0,u0,beta0,a.e,g.e,a.u,g.u){
  n<-dim(X)[1]
  p<-dim(X)[2]
  q<-dim(Z)[2]
  W <-cbind(X,Z)
  WTW<-crossprod(W)
  WTY<-crossprod(W,y)
  Kinvall<-matrix(0,p+q,p+q)
  Kinvall[-c(1:p),-c(1:p)]<-Kinv
  
  for(i in 1:iter){
    Vub <-solve(taue_0*WTW+tauu_0*Kinvall) #update Var(b,u)
    ub  <-taue_0*Vub%*%WTY                 #update E(b,u)
    TrKinvub <- sum(diag(Kinvall%*%Vub))
    uKinvub  <- t(ub)%*%Kinvall%*%ub
    tauu    <- (a.u+0.5*q)/(g.u+0.5*as.numeric(uKinvub)+0.5*TrKinvub)
    tauu    <- as.numeric(tauu)
    err     <- y - W%*%ub
    TrWTWub  <- sum(diag(WTW%*%Vub))
    taue    <- (a.e+0.5*n)/(g.e+0.5*sum(err^2)+0.5*TrWTWub)
    taue    <- as.numeric(taue)
    
    if(i > 1){
      diffub  <- sqrt((ub-ub0)^2)/(abs(ub)+0.01)
      diffte <- abs(taue_0-taue)/(taue+0.01)
      difftu <- abs(tauu_0-tauu)/(tauu+0.01)
      diffvub <- sqrt((diag(Vub0) - diag(Vub))^2)/(diag(Vub))
      diff.all<-c(diffub,diffte,difftu,diffvub)
      if(max(diff.all) < epsilon) break
    }
    Vub0 <- Vub;ub0<-ub;taue_0<-taue;tauu_0<-tauu
    #Calculate relative change.
  }
  
  taue.param<-c((a.e+0.5*n),(g.e+0.5*sum(err^2)+0.5*TrWTWub))
  tauu.param<-c((a.u+0.5*q),(g.u+0.5*uKinvub+0.5*TrKinvub))  
  param<-list(ub,Vub,taue.param,tauu.param,i)
  names(param)<-c('betau_mean','betau_var','tau_e','tau_u','iter')
  return(param)
}




##########################
#Generate random effect levels for simulation where q =5 
n<-300
q<-5 #so n per q = 60
u.sim <-rnorm(n=q,mean=0,sd=1)
u.sim <-scale(u.sim)
Z<-table(1:n,rep(1:q,n/q))
beta.sim<-c(0.5,-2,3)
X   <-cbind(1,matrix(rnorm(n*2),n,2))
y<- X%*%beta.sim + Z%*%u.sim + rnorm(n=n,mean=0,sd=sqrt(2))

system.time(test1.1<-normalmm.Gibbs(iter=10000,Z=Z,X=X,y=y,burnin=2000,taue_0=3,tauu_0=0.5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test2.1<-normalmm.Gibbs(iter=10000,Z=Z,X=X,y=y,burnin=2000,taue_0=0.5,tauu_0=3,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test3.1<-normalmm.Gibbs(iter=10000,Z=Z,X=X,y=y,burnin=2000,taue_0=5,tauu_0=5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))

system.time(test1.vb<-VB.mm(epsilon=1e-6,iter=100,Kinv=diag(q),Z=Z,X=X,y=y,taue_0=3,tauu_0=0.5,u0=rnorm(q),beta0=rnorm(3),a.e=0,g.e=0,a.u=0,g.u=0))


#change to q = 10
q<-10 #So n per q = 30
u.sim2 <-rnorm(n=q,mean=0,sd=1)
u.sim2 <-scale(u.sim2)
Z2<-table(1:n,rep(1:q,n/q))
y2<- y-Z%*%u.sim + Z2%*%u.sim2

system.time(test1.2<-normalmm.Gibbs(iter=10000,Z=Z2,X=X,y=y2,burnin=2000,taue_0=3,tauu_0=0.5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test2.2<-normalmm.Gibbs(iter=10000,Z=Z2,X=X,y=y2,burnin=2000,taue_0=0.5,tauu_0=3,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test3.2<-normalmm.Gibbs(iter=10000,Z=Z2,X=X,y=y2,burnin=2000,taue_0=5,tauu_0=5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))

system.time(test2.vb<-VB.mm(epsilon=1e-6,iter=100,Kinv=diag(q),Z=Z2,X=X,y=y2,taue_0=3,tauu_0=0.5,u0=rnorm(q),beta0=rnorm(3),a.e=0,g.e=0,a.u=0,g.u=0))

#change q again to 20
q<-20 #So n per q is 15
u.sim3 <-rnorm(n=q,mean=0,sd=1)
u.sim3 <-scale(u.sim3)
Z3<-table(1:n,rep(1:q,n/q))
y3<- y2-Z2%*%u.sim2 + Z3%*%u.sim3

system.time(test1.3<-normalmm.Gibbs(iter=10000,Z=Z3,X=X,y=y3,burnin=2000,taue_0=3,tauu_0=0.5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test2.3<-normalmm.Gibbs(iter=10000,Z=Z3,X=X,y=y3,burnin=2000,taue_0=0.5,tauu_0=3,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test3.3<-normalmm.Gibbs(iter=10000,Z=Z3,X=X,y=y3,burnin=2000,taue_0=5,tauu_0=5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))

system.time(test3.vb<-VB.mm(epsilon=1e-6,iter=100,Kinv=diag(q),Z=Z3,X=X,y=y3,taue_0=3,tauu_0=0.5,u0=rnorm(q),beta0=rnorm(3),a.e=0,g.e=0,a.u=0,g.u=0))


#change q again to 50.
q<-50 #So n per q is 6
u.sim4 <-rnorm(n=q,mean=0,sd=1)
u.sim4 <-scale(u.sim4)
Z4<-table(1:n,rep(1:q,n/q))
y4<- y3-Z3%*%u.sim3 + Z4%*%u.sim4

system.time(test1.4<-normalmm.Gibbs(iter=10000,Z=Z4,X=X,y=y4,burnin=2000,taue_0=3,tauu_0=0.5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test2.4<-normalmm.Gibbs(iter=10000,Z=Z4,X=X,y=y4,burnin=2000,taue_0=0.5,tauu_0=3,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test3.4<-normalmm.Gibbs(iter=10000,Z=Z4,X=X,y=y4,burnin=2000,taue_0=5,tauu_0=5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))

system.time(test4.vb<-VB.mm(epsilon=1e-6,iter=100,Kinv=diag(q),Z=Z4,X=X,y=y4,taue_0=3,tauu_0=0.5,u0=rnorm(q),beta0=rnorm(3),a.e=0,g.e=0,a.u=0,g.u=0))

#change q again to 100
q<-100 #So n per q is 3
u.sim5 <-rnorm(n=q,mean=0,sd=1)
u.sim5 <-scale(u.sim5)
Z5<-table(1:n,rep(1:q,n/q))
y5<- y4-Z4%*%u.sim4 + Z5%*%u.sim5

system.time(test1.5<-normalmm.Gibbs(iter=10000,Z=Z5,X=X,y=y5,burnin=2000,taue_0=3,tauu_0=0.5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test2.5<-normalmm.Gibbs(iter=10000,Z=Z5,X=X,y=y5,burnin=2000,taue_0=0.5,tauu_0=3,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))
system.time(test3.5<-normalmm.Gibbs(iter=10000,Z=Z5,X=X,y=y5,burnin=2000,taue_0=5,tauu_0=5,Kinv=diag(q),a.u=0,b.u=0,a.e=0,b.e=0))

system.time(test5.vb<-VB.mm(epsilon=1e-6,iter=100,Kinv=diag(q),Z=Z5,X=X,y=y5,taue_0=3,tauu_0=0.5,u0=rnorm(q),beta0=rnorm(3),a.e=0,g.e=0,a.u=0,g.u=0))

#You need to check the column of par have converged.
#For this use the coda library and convert into mcmc object.
#See 314 notes for how to do this. 

colMeans(test1.1$par)
colMeans(test2.1$par)
colMeans(test3.1$par)

colMeans(test1.2$par)
colMeans(test2.2$par)
colMeans(test3.2$par)

colMeans(test1.3$par)
colMeans(test2.3$par)
colMeans(test3.3$par)

colMeans(test1.4$par)
colMeans(test2.4$par)
colMeans(test3.4$par)

colMeans(test1.5$par)
colMeans(test2.5$par)
colMeans(test3.5$par)

#For graphical evidence of convergence of tau_u (ca)
plot(density(test1.1$par[,'tau_u']),main=expression(paste('Estimate of ',tau['u'],', q=5,  n'['q'], ' =60')))
lines(density(test2.1$par[,'tau_u']),col=2)
lines(density(test3.1$par[,'tau_u']),col=3)

plot(density(test1.2$par[,'tau_u']),main=expression(paste('Estimate of ',tau['u'],', q=10,  n'['q'], ' =30')))
lines(density(test2.2$par[,'tau_u']),col=2)
lines(density(test3.2$par[,'tau_u']),col=3)

plot(density(test1.3$par[,'tau_u']),main=expression(paste('Estimate of ',tau['u'],', q=20,  n'['q'], ' =15')))
lines(density(test2.3$par[,'tau_u']),col=2)
lines(density(test3.3$par[,'tau_u']),col=3)

plot(density(test1.4$par[,'tau_u']),main=expression(paste('Estimate of ',tau['u'],', q=50,  n'['q'], ' =6')))
lines(density(test2.4$par[,'tau_u']),col=2)
lines(density(test3.4$par[,'tau_u']),col=3)

plot(density(test1.5$par[,'tau_u']),main=expression(paste('Estimate of ',tau['u'],', q=100,  n'['q'], ' =3')))
lines(density(test2.5$par[,'tau_u']),col=2)
lines(density(test3.5$par[,'tau_u']),col=3)


#Combine plots of tau_u for each run (you need to check convergence) and superimpose
tau.uq5<-c(test1.1$par[,'tau_u'],test2.1$par[,'tau_u'],test3.1$par[,'tau_u'])
tau.uq10<-c(test1.2$par[,'tau_u'],test2.2$par[,'tau_u'],test3.2$par[,'tau_u'])
tau.uq20<-c(test1.3$par[,'tau_u'],test2.3$par[,'tau_u'],test3.3$par[,'tau_u'])
tau.uq50<-c(test1.4$par[,'tau_u'],test2.4$par[,'tau_u'],test3.4$par[,'tau_u'])
tau.uq100<-c(test1.5$par[,'tau_u'],test2.5$par[,'tau_u'],test3.5$par[,'tau_u'])

#Save reference data to RDS file
dr_john_ref <- list(
  gibbs = list(
    q5   = tau.uq5,
    q10  = tau.uq10,
    q20  = tau.uq20,
    q50  = tau.uq50,
    q100 = tau.uq100
  ),
  vb = list(
    q5   = test1.vb$tau_u,
    q10  = test2.vb$tau_u,
    q20  = test3.vb$tau_u,
    q50  = test4.vb$tau_u,
    q100 = test5.vb$tau_u
  )
)
saveRDS(dr_john_ref, "d:/github/VI1/results/dr_john_working_tau_u.rds")
cat("Saved reference data to: d:/github/VI1/results/dr_john_working_tau_u.rds\n")

#Plot the posterior distribution (as sampled using a Gibbs sampling algorithm) and the VB approximate posterior.
png(filename="d:/github/VI1/figs/dr_john_tau_QPosteriorVB_working.png", width=800, height=600, res=100)
plot(density(tau.uq5),xlab=expression(tau['u']),main='',ylim=c(0,2.5),lwd=2)
lines(density(tau.uq10),col=2,lwd=2)
lines(density(tau.uq20),col=3,lwd=2)
lines(density(tau.uq50),col=4,lwd=2)
lines(density(tau.uq100),col=5,lwd=2)
#Add on the approximate posterior. 
curve(dgamma(x,test1.vb$tau_u[1],test1.vb$tau_u[2]),add=TRUE,lty=2,lwd=2)
curve(dgamma(x,test2.vb$tau_u[1],test2.vb$tau_u[2]),add=TRUE,lty=2,lwd=2,col=2)
curve(dgamma(x,test3.vb$tau_u[1],test3.vb$tau_u[2]),add=TRUE,lty=2,lwd=2,col=3)
curve(dgamma(x,test4.vb$tau_u[1],test4.vb$tau_u[2]),add=TRUE,lty=2,lwd=2,col=4)
curve(dgamma(x,test5.vb$tau_u[1],test5.vb$tau_u[2]),add=TRUE,lty=2,lwd=2,col=5)
legend('topright',col=c(1:5,1,1),lty=c(0,0,0,0,0,1,2),pch=19,legend=c('q=5','q=10','q=20','q=50','q=100','Posterior','VB approximation'))
dev.off()
cat("Saved plot to: d:/github/VI1/figs/dr_john_tau_QPosteriorVB_working.png\n")
