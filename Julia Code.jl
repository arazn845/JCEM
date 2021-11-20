
using JuMP
using Gurobi
bar=Model(solver = GurobiSolver())
  
s = s
N = N
M = M
W = W
T = T
K = K
d = d
b1 = b1
b2 = b2
BY = BY
l = l
q = q


@variable(bar,x[1:N, 1:M, 1:K, 1:T],Bin)
@variable(bar,a[1:W, 1:M, 1:T],Bin)
#Variable
@variable(bar, C[1:N,1:M])
@variable(bar, p[1:N,1:M])
@variable(bar, v[1:N,1:M])
@constraint(bar, CC[i=1:N, j=1:M], C[i,j]-p[i,j]==v[i,j] )

@variable(bar, PT) #profit
@variable(bar, Q) #revenue
@variable(bar, time)
@variable(bar, B1) #trainingcost
@variable(bar, B2) #salarycost
@variable(bar, B3) #fixedcost

@variable(bar, pi[1:N,1:M]) #practical operation mode
@constraint(bar, Cpi[i=1:N, j=1:M], sum(x[i,j,k,t]*k for t=1:T for k=1:K)==pi[i,j])
#objective
@objective(bar,Max,PT)
#constraints
@constraint(bar, C1[i=1:N, j=1:M], sum(x[i,j,k,t] for t=1:T for k=1:K)==1)
@constraint(bar, C2[i=1:N, j=1:M], sum(d[i,j,k]*x[i,j,k,t] for k=1:K for t=1:T)==p[i,j] )
@constraint(bar, C3[i=1:N, j=1:M], sum(x[i,j,k,t]*t for k=1:K for t=1:T)==C[i,j])
@constraint(bar, C4[i= 1:N,j=2:M], C[i,(j-1)]+p[i,j]<=C[i,j] )
@constraint(bar, C5a[j=1:M], C[2,j]>=C[1,j]+p[2,j])
@constraint(bar, C5b[j=1:M], C[3,j]>=C[2,j]+p[3,j])
@constraint(bar, C5b[j=1:M], C[4,j]>=C[3,j]+p[4,j])
@constraint(bar, C5b[j=1:M], C[5,j]>=C[4,j]+p[5,j])

@constraint(bar, C5E[i= 1:N,j=1:M],C[i,j]-p[i,j]>=0)
@constraint(bar, C6[h=1:W, j=1:M, t=1:T],a[h,j,t]<=s[h,j] )
@constraint(bar, C7[h=1:W, t=1:T], sum(a[h,j,t] for j=1:M) <=1 )
@constraint(bar, C4[i= 1:N,j=1:M],sum(x[i,j,k,t]*a[h,j,t] for h=1:W for t=1:T for k=1:K)-sum(x[i,j,k,t]*k for t=1:T for k=1:K)==0)
@constraint(bar, C13[i= 1:N,j=1:M,h=1:W],sum(x[i,j,k,t]*a[h,j,l] for k=1:K for t=d[i,j,k]:T for l=t-d[i,j,k]+1:t)-sum(x[i,j,k,t]*d[i,j,k]*a[h,j,t] for k=1:K for t=d[i,j,k]:T)==0)

@constraint(bar, C14,sum(s[h,j]*b1[h,j] for h=1:W for j=1:M)==B1) #trainingcost
@constraint(bar, C16,sum{t*x[N,M,k,t]*l,k=1:K,t=1:T}==B3) #fixedcost
@constraint(bar, C17,sum{x[i,M,k,t]*q[i],i=1:N,k=1:K,t=1:T}==Q) #revenue
@constraint(bar, C18,PT== Q-B1-B3) #profit

#@constraint(bar, C19[h=h1],sum(a[h,j,t] for j=1:M for t=[t1:t2]) ==0) #absentissm


solve(bar)
getvalue(C[N,M])



println("PT: ", getvalue(PT), "    Q: ", getvalue(Q), "    B1: ", getvalue(B1), "    B3: ", getvalue(B3), "    time: ", getvalue(C[N,M]))
