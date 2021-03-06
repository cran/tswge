fore.arma.wge=function(x,phi=0,theta=0,n.ahead=2,lastn=FALSE, plot=TRUE,limits=TRUE)
{
# lastn=TRUE indicates that the last n data values are to be forecast
# lastn=FALSE (default) indicates we want foreacts for n values beyond the end of the realization
n=length(x)
p=length(phi)
if(sum(phi^2)==0) {p=0}
q=length(theta)
if(sum(theta^2)==0) {q=0}
resid=rep(0,n)
npn.ahead=n+n.ahead
xhat=rep(0,npn.ahead)
xbar=mean(x)
const=1
if (p > 0) {for(jp in 1:p) {const=const-phi[jp]}}
#
#
# Calculate Box-Jenkins Forecasts
#
#
#Calculating Residuals
#
#
maconst=const*xbar
p1=max(p+1,q+1)
for (i in p1:n) {resid[i]=x[i]
   if ( p > 0) {for (jp in 1:p) {resid[i]=resid[i]-phi[jp]*x[i-jp]}}
   if (q > 0) {for (jq in 1:q) {resid[i]=resid[i]+theta[jq]*resid[i-jq]}}
                   resid[i]=resid[i]-maconst}
#
# Calculating Forecasts
#
#
npn.ahead=n+n.ahead
xhat=rep(0,npn.ahead)
mm=n
#
#lastn = TRUE
#
if(lastn==TRUE) {mm=n-n.ahead}
#
#
for (i in 1:mm) {xhat[i]=x[i]}
for (h in 1:n.ahead) {
if (p > 0) {for (jp in 1:p) {xhat[mm+h]=xhat[mm+h]+phi[jp]*xhat[mm+h-jp]}}
if ((h<=q)&(h>0)) {for(jq in h:q) {xhat[mm+h]=xhat[mm+h]-theta[jq]*resid[mm+h-jq]}}
                    xhat[mm+h]=xhat[mm+h]+maconst}
#
#
#   Calculate psi weights for forecasts limits
#
#
xi=psi.weights.wge(phi,theta,lag.max=n.ahead)
#
#
#
#Setting up for plots
nap1=n.ahead+1
fplot=rep(0,nap1)
maxh=mm+n.ahead
llplot=rep(0,nap1)
ulplot=rep(0,nap1)
f=rep(0,nap1)
ll=rep(0,nap1)
ul=rep(0,nap1)
wnv=0
xisq=rep(0,n.ahead)
se=rep(0,n.ahead)
se0=1
for (i in p1:n) {wnv=wnv+resid[i]**2}
wnv=wnv/(n-p)
xisq[1]=1
for (i in 2:n.ahead) {xisq[i]=xisq[i-1]+xi[i-1]^2}
for (i in 1:n.ahead) {se[i]=sqrt(wnv*xisq[i])}
fplot[1]=x[mm]
for (i in 1:n.ahead) {fplot[i+1]=xhat[mm+i]}
ulplot[1]=x[mm]
for (i in 1:n.ahead) { ulplot[i+1]=fplot[i+1]+1.96*se[i]}
llplot[1]=x[mm]
for (i in 1:n.ahead) { llplot[i+1]=fplot[i+1]-1.96*se[i]}
#
if(limits==FALSE) {
  if(lastn==TRUE) {max=max(x,xhat[1:n])
  min=min(x,xhat[1:n])}
  else            {max=max(x,xhat)
  min=min(x,xhat)}}
if(limits==TRUE) {min=min(x,llplot)
max=max(x,ulplot)}
numrows <- 1
numcols <- 1
timelab <- 'Time'
valuelab <- ''
fig.width <- 5
fig.height <- 2.5
cex.labs <- c(.8,.7,.8)
par(mfrow=c(numrows,numcols),mar=c(3.8,2.5,1,1))
t<-1:n;
np1=n+1
np.ahead=mm+n.ahead
tf<-mm:np.ahead
if (plot=='TRUE') {
fig.width <- 5
fig.height <- 2.5
cex.labs <- c(.8,.7,.8)
par(mfrow=c(numrows,numcols),mar=c(3.8,2.5,1,1))
plot(t,x,type='o',xaxt='n',yaxt='n',cex=.4,pch=16,cex.lab=.75,cex.axis=.75,lwd=.75,xlab='',ylab='',xlim=c(1,maxh),ylim=c(min,max))
axis(side=1,cex.axis=.4,mgp=c(3,0.15,0),tcl=-.3);
axis(side=2,las=1,cex.axis=.4,mgp=c(3,.4,0),tcl=-.3)
mtext(side=c(1,2,1),cex=cex.labs,text=c(timelab,valuelab,""),line=c(.8,1.1,1.8))
points(tf,fplot,type='o',lty=3,cex=.4,lwd=2,pch=1);
if(limits=='TRUE') {points(tf,ulplot,type='l',lty=3,cex=0.6,lwd=.75,pch=1)
points(tf,llplot,type='l',lty=3,cex=0.6,lwd=.75,pch=1) }
    }
np1=n+1
nap1=n.ahead+1
f=fplot[2:nap1]
ll=llplot[2:nap1]
ul=ulplot[2:nap1]
out1=list(f=f,ll=ll,ul=ul,resid=resid,wnv=wnv,se=se,psi=xi)
return(out1)
}