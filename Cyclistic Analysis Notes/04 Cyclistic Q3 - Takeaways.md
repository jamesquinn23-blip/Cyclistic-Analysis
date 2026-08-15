# Current takeaways - Start Stations

## For all rides where start_station_name IS NOT NULL across the data we see:

**Total Rides** and **Rides under one hour**:
> `member` **Total Rides** and **Rides under one hour** have the same 10 named start_stations and similar concentrations.
> `casual` **Total Rides** and **Rides under one hour** have the same 10 named start_stations and similar concentrations.
> This isn't surprising, because **Rides under one hour** make up ~93% (`casual`) and ~98% (`member`) of **Total Rides**.

**Rides between one and two hours**:
> `member` and `casual` start_stations have 6 overlapping start_stations among each cohorts top 10:
> > `Navy Pier`
> > `DuSable Lake Shore Dr & Monroe St`
> > `Michigan Ave & Oak St`
> > `DuSable Harbor`
> > `DuSable Lake Shore Dr & North Blvd`
> > `Theater on the Lake`

`member` concentrations are lower than `casual` concentrations.
	Top 4 `casual` stations equal 16.70% of rides in this cohort.
	Top 4 `member` stations equal 4.73% of rides in this cohort.
`casual` ride starts seem to be centered around lakefront, tourist and leisure activities.

### Top ~10% rides named start stations `member`

```
start_station_name	start_lat	start_lng	member_starts	percent_of_member_starts	running_count	total_count
Canal St & Madison St	41.882405199704614	-87.63976336229096	24596	0.7499436688515123	24596	3279713
State St & Chicago Ave	41.896616584249834	-87.62858111487174	22778	0.6945119893112598	47374	3279713
Clinton St & Madison St	41.882376883364756	-87.64117953037199	21842	0.6659729067756843	69216	3279713
Clinton St & Washington Blvd	41.88325320674658	-87.64118478886681	21629	0.6594784360704733	90845	3279713
Wells St & Elm St	41.90321950670318	-87.6343383649953	21389	0.6521607225998128	112234	3279713
Wells St & Concord Ln	41.912130836661106	-87.6346576882898	21193	0.6461845899321069	133427	3279713
Clinton St & Jackson Blvd	41.87831866583077	-87.6409850452961	20743	0.6324638771746186	154170	3279713
Clark St & Elm St	41.902967802589394	-87.63131825995205	20463	0.6239265447921815	174633	3279713
Kingsbury St & Kinzie St	41.88917004876158	-87.63849737725806	20155	0.6145354791715006	194788	3279713
Wells St & Huron St	41.89479069795535	-87.63438017425372	19896	0.6066384467177464	214684	3279713
Wells St & Hubbard St	41.889909128580655	-87.63426946119475	17611	0.5369677163825005	232295	3279713
DuSable Lake Shore Dr & North Blvd	41.9117222529834	-87.62680404328518	17422	0.5312050170243555	249717	3279713
Desplaines St & Kinzie St	41.88871133968696	-87.6444475735603	17368	0.5295585314934569	267085	3279713
Kingsbury St & Erie St	41.89390683680707	-87.64173767759013	17199	0.5244056415912002	284284	3279713
Canal St & Adams St	41.87925497594855	-87.6399067117334	16908	0.5155329140080245	301192	3279713
Clark St & Armitage Ave	41.91830592063583	-87.63628337191471	16766	0.5112032668712171	317958	3279713
University Ave & 57th St	41.79147792376171	-87.59986220993873	16643	0.5074529387175036	334601	3279713

```

### Top ~10% of rides start station casual
```
end_station_name	end_lat	end_lng	casual_stops	percent_of_member_stops	running_count	total_count
Navy Pier	41.89227800000531	-87.61204299999633	47271	2.637858240579636	47271	1792022
DuSable Lake Shore Dr & Monroe St	41.88095800358709	-87.61674300022928	34310	1.9145970306168116	81581	1792022
Michigan Ave & Oak St	41.900960389997955	-87.623776639997	26848	1.4981958926843533	108429	1792022
DuSable Lake Shore Dr & North Blvd	41.911722001343726	-87.62680400103369	26339	1.4697922235329701	134768	1792022
Millennium Park	41.88103170000154	-87.62408432000133	22144	1.23569911530104	156912	1792022
Theater on the Lake	41.926277000000205	-87.63083400000495	20619	1.1505997136195873	177531	1792022
Shedd Aquarium	41.86722596134828	-87.61535540232624	17160	0.9575775297401483	194691	1792022
```

```
```