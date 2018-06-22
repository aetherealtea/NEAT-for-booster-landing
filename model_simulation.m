%%%%%%%%%%%%%%%% XOR experiment file  (contains experiment, receives genom, decodes it, evaluates it and returns raw fitnesses) (function)

%% Neuro_Evolution_of_Augmenting_Topologies - NEAT 
%% developed by Kenneth Stanley (kstanley@cs.utexas.edu) & Risto Miikkulainen (risto@cs.utexas.edu)
%% Coding by Christian Mayr (matlab_neat@web.de)

function population_plus_fitnesses=model_simulation(population)

population_plus_fitnesses=population;




number_individuals=size(population,2);

for i=1:number_individuals
   number_nodes(i)=size(population(i).nodegenes,2);
   number_connections(i)=size(population(i).connectiongenes,2);
   
    %1-9 - input; 10 - bias; 11-12 - output; 13+ - hidden
      % set node input steps for first timestep
      population(i).nodegenes(3,11:number_nodes)=0; %set all node input states to zero
      population(i).nodegenes(3,10)=1; %bias node input state set to 1
      population(i).nodegenes(3,1:9)=0; %node input states of the two input nodes are set to zero  
      
      %set node output states for first timestep (depending on input states)
      population(i).nodegenes(4,1:9)=population(i).nodegenes(3,1:9);
      population(i).nodegenes(4,11:number_nodes)=-1+2./(1+exp(-4.9*population(i).nodegenes(3,11:number_nodes)));
     
     nodegenes{i} = population(i).nodegenes;
     connectiongenes{i} = population(i).connectiongenes;
end
   
             
parfor index_individual=1:number_individuals   
   
   fitness1=3000;
   fitness2=3000;
      mkdir(tempname());  
      load_system('NEAT_NN_Par_Controller_3');
      nodegenes_sim = num2str(nodegenes{index_individual});
      connectiongenes_sim = num2str(connectiongenes{index_individual});
      
      set_param('NEAT_NN_Par_Controller_3/Constant3','Value',strcat('[',num2str(number_nodes(index_individual)),', ',num2str(number_connections(index_individual)),']'));
      
      nodestr='';
      for k = 1:4
          nodestr = strcat(nodestr, '[', nodegenes_sim(k, :), '];');
      end
      connectionstr='';
      for k = 1:5
          connectionstr = strcat(connectionstr, '[', connectiongenes_sim(k, :), '];');
      end
      
      set_param('NEAT_NN_Par_Controller_3/Constant4','Value',strcat('[',nodestr, ']'));
        set_param('NEAT_NN_Par_Controller_3/Constant5','Value',strcat('[',connectionstr, ']'));
      Xinit = 50;
      Zinit = -300;
      set_param('NEAT_NN_Par_Controller_3/First Stage Model','pos_ini',strcat('[',num2str(Xinit),', ',num2str(Zinit),']'));
      %model simulation
      [sim_t, sim_x, X0, Z0, Theta, V] = sim('NEAT_NN_Par_Controller_3');
      time = size(sim_t);
      time = time(1);
      i=1;
        while (-Z0(i)>0.5)&&(i<time)
            i=i+1;
        end;
        if i<time
            V0 = sqrt(V(i,1)^2+V(i,2)^2);
            fitness1 = abs(V0) + abs(X0(i))/5+abs(90-abs(Theta(i))/pi*180);
        end;
      
        
      Xinit = -50;
      Zinit = -400;
      set_param('NEAT_NN_Par_Controller_3/First Stage Model','pos_ini',strcat('[',num2str(Xinit),', ',num2str(Zinit),']'));
      %model simulation
      [sim_t, sim_x, X0, Z0, Theta, V] = sim('NEAT_NN_Par_Controller_3');
      i=1;
      time = size(sim_t);
      time = time(1);
        while (-Z0(i)>0.5)&&(i<time)
            i=i+1;
        end;
        if i<time
            V0 = sqrt(V(i,1)^2+V(i,2)^2);
            fitness2 = abs(V0) + abs(X0(i))/5+abs(90-abs(Theta(i))/pi*180);
        end;
      

   population_plus_fitnesses(index_individual).fitness=10000-fitness1-fitness2; %Fitness function as defined by Kenneth Stanley    

end
