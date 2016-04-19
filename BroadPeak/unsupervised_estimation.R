set.seed(1)

    args = (commandArgs(TRUE));
        
    if(length(args) == 0)
    {
       cat("No arguments supplied");
    }else
    {
       for(i in 1:length(args))
       {
          eval(parse(text=args[[i]]));
       }
    }


    input = paste(identifier,"/region_for_unsupervised_estimation/data_for_estimation.bed",sep="");
    output = paste(identifier,"/unsupervised_estimation/unsupervised_parameter_score.txt",sep="");
    data = read.table(input);
    
    win = 5;
    
    data = as.matrix(data);
    region_num = dim(data)[1];
    N = dim(data)[2];
    
    lamda_array = as.array(rep(0,region_num));
    alpha1_array = as.array(rep(0,region_num));
    beta1_array = as.array(rep(0,region_num));
    delta1_array = as.array(rep(0,region_num));
    epslon1_array = as.array(rep(0,region_num));
    
    
    miu_array = as.array(rep(0,region_num));
    alpha2_array = as.array(rep(0,region_num));
    beta2_array = as.array(rep(0,region_num));
    delta2_array = as.array(rep(0,region_num));
    epslon2_array = as.array(rep(0,region_num));
    
    
    c_array = as.array(rep(0,region_num));
    
    
    for(r in 1:region_num)
    {
         series = as.array(data[r,]);
         
         temp_mean_1 = mean(series[1:5])+0.01;
         temp_mean_2 = mean(series[15:20])+0.01;
         
         temp_var_1 = var(series[1:5])+0.01;
         temp_var_2 = var(series[15:20])+0.01;
         
         
         S = cumsum(series);
         
         lamda = temp_mean_1;
         miu = temp_mean_2;
         
         c = 1+floor(N*runif(1));
         
         beta1 = temp_mean_1/temp_var_1;
         beta2 = temp_mean_2/temp_var_2;
         
         
         alpha1 = temp_mean_1*beta1;
         alpha2 = temp_mean_2*beta2;
        
         
         delta1 = beta1*2;
         delta2 = beta2*2;
         
         epslon1 = 0.5;
         epslon2 = 0.5;
         
         for(s in 1:20)
         {
                      
              lamda = rgamma(1,alpha1+S[c],beta1+c);
              
              miu = rgamma(1,alpha2+S[N]-S[c],beta2+N-c);
              
              beta1 = rgamma(1,alpha1+delta1,lamda+epslon1);
              
              beta2 = rgamma(1,alpha2+delta2,miu+epslon2);
              
              if(lamda <= 0){lamda = 0.001};
              if(miu <= 0){miu = 0.001};

              
              L = as.array(rep(0,N));
              for(k in 1:N)
              {
                L[k] = exp(k*(miu-lamda)+S[k]*(log(lamda)-log(miu))-N*miu+S[N]*log(miu));
                
              }
              
              p = L/sum(L);
              cumprob = cumsum(p);
              
              
              U = runif(1);
              
              c=1;
              for(i in 1:(N-1))
              {
                 if((cumprob[i]<U)&&(U<=cumprob[i+1])) c <- i;
                 
              }
              
             
         }
         
         lamda_array[r] = lamda;
         miu_array[r] = miu;
        
       
    }
    
    
    file.create(output);
    
    
    p = mean(miu_array)/win;
    q = mean(lamda_array)/win;
    
    cat("p","\t",p,"\n",file=output,append="TRUE");
    cat("q","\t",q,"\n",file=output,append="TRUE");
    
    cat("s1","\t",log(p/q),"\n",file=output,append="TRUE");
    cat("s2","\t",log((1-p)/(1-q)),"\n",file=output,append="TRUE");
    
