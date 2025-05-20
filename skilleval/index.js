(() => {
	const scoring = {
		b: {score: 4, name: 'beginner'},
		i: {score: 8, name: 'intermediate'},
		a: {score: 12, name: 'advanced'},
		e: {score: 16, name: 'expert'},
		none: {score: 0, name: 'none'}
	};

	const criteria = [
		{name: 'General play', items: [
			{label: "Checking settings page", score: 'b'},
			{label: "Checking statistics page", score: 'b'},
			{label: "Ability to perform mathematics in real time", help: `Add, subtract, divide, multiply; can be done with calculator`, score: 'b'},
			{label: "Understanding what each setting stands for", help: `For example local deployment means that you can only deploy bonus' income within bonus' boundaries`, score: 'b'},
			{label: "Knowing how to use game history", score: 'b'},
			{label: "Knowing how to check territory connections", score: 'b'},
			{label: "Finding which territory belongs to which bonus", score: 'b'},
			{label: "Calculating how many picks in total all the players get", score: 'b'},
			{label: "Identifying wastelands", score: 'b'},
			{label: "Keeping track of held cards", score: 'b'},
			{label: "Spotting all opponent's visible territories", score: 'b'},
			{label: "Knowing which territories connect across the map", help: `For example Hawaii connecting to Japan on Medium Earth map`, score: 'b'},
			{label: "Keeping track of where your armies happen to be on the map", score: 'b'},
			{label: "Finding shortest path from territory X to territory Y", score: 'b'},
			{label: "Finding out minimal amount of armies needed to take down a territory", score: 'b'},
			{label: "Noticing which picks were lost to opponent during picking stage", score: 'b'},
			{label: "Calculating bonus takeover speed", help: `In how many turns can you take the bonus`, score: 'i'},
			{label: "Finding income per territory ratio", help: `Bonus income divided by territory amount`, score: 'i'},
			{label: "Calculating defender and attacker loses during the attack", score: 'i'},
			{label: "Finding out territory take over cost", help: `Defending stack*defending kill rate + 1 if 1 army stand guard is on`, score: 'i'},
			{label: "Understanding concept of delay moves", score: 'i'},
			{label: "Prioritizing move order", help: `Which moves should be first and which should be last`, score: 'i'},
			{label: "Identifying bottlenecks", help: `A one way corridor between territories with no alternative routes`, score: 'i'},
			{label: "Identifying strong and weak positional points for bonuses", help: `Positional point is when from one territory you can attack 2+ different territories in another bonus. Strong point is beneficial to you, weak point is something which can be used by opponent`, score: 'i'},
			{label: "Finding 1st turn bonuses", score: 'i'},
			{label: "Understanding map coverage", help: `Further apart picks allow more opportunities for expanding or targeting opponent`, score: 'i'},
			{label: "Ability to concentrate expansion efforts", help: `Avoiding over expansion`, score: 'i'},
			{label: "Identifying opponent's minimum income", score: 'i'},
			{label: "Deciding when it is worth to defend", help: `For example on standard kill rate, if you lose 100% defenders, they only kill 100%*0.7 of their value in return, so in other words if you lose your defending stack, you're the one losing more armies`, score: 'i'},
			{label: "Deciding between expanding or engaging the opponent", score: 'i'},
			{label: "Launching a surprise attack", help: `For example targeting bonuses which were lost during picking stage`, score: 'i'},
			{label: "Understanding the concept of counter attack", score: 'i'},
			{label: "Counting opponent's visible moves", score: 'i'},
			{label: "Finding the means to successfully gain card pieces", help: `You need to capture at least one territory per turn to get card pieces`, score: 'i'},
			{label: "Identifying the least useful cards when forced to discard them", score: 'i'},
			{label: "Understanding how move order goes", score: 'i'},
			{label: "Knowing the difference between main and back up picks", help: `You get back up picks if you lose main picks`, score: 'i'},
			{label: "Anticipating opponent deploying additional armies to his stack and adjusting attack/defense size accordingly", score: 'i'},
			{label: "Safe picking", help: `Picking bonuses without weak points`, score: 'i'},
			{label: "Pick stealing", help: `Determining where opponent goes and trying to pick those picks as well`, score: 'i'},
			{label: "Pick countering", help: `Picking in a way to prevent opponent from taking bonuses`, score: 'i'},
			{label: "Relative safety", help: `Bonuses which become safe to pick due to nearby wastelands`, score: 'i'},
			{label: "Detecting player activity based upon unusual size neutrals", score: 'i'},
			{label: "Calculating leftover amount", help: `Attacking stack size minus territory takeover cost`, score: 'a'},
			{label: "Understanding the concept of chain expansion", help: `Using leftovers for cheaper expansion`, score: 'a'},
			{label: "Calculating total takeover cost of bonus", help: `All territory cost within bonus combined`, score: 'a'},
			{label: "Finding income per cost ratio", help: `Bonus income divided from bonus cost`, score: 'a'},
			{label: "Calculating bonus payback time", help: `How many turns it takes for bonus to generate more than it cost to take said bonus`, score: 'a'},
			{label: "Identifying efficient bonus clusters", help: `Many valuable bonuses close to each other`, score: 'a'},
			{label: "Identifying bonus regions", help: `Groups of bonuses separated by bottlenecks`, score: 'a'},
			{label: "Calculating relative income per territory/income per cost/payback cost time", help: `If you happen to already have some territories in the bonus, it means that taking remainder of bonus is cheaper when starting from scratch`, score: 'a'},
			{label: "Value of starting bonus versus other bonuses", help: `You already get 1+ territory with x+ free armies in your starting bonuses, plus other bonuses can start with mini wastelands if other players don't pick them`, score: 'a'},
			{label: "Understanding how move order works", help: `For 1v1 if goes A1 B1 B2 A2 A3 B3 B4 A4 ...`, score: 'a'},
			{label: "Determining move order based upon game history", score: 'a'},
			{label: "Determining how many hidden orders player made based on game history", score: 'a'},
			{label: "Counting opponent's hidden income based upon hidden deploy orders", help: `Each hidden deploy order must be at least 1 deployed army`, score: 'a'},
			{label: "Masking your own deploy and move orders", help: `Orders which opponent can see go first, order which cannot be seen by opponent go last`, score: 'a'},
			{label: "Guaranteeing region presence during picking stage", help: `For example if you lose 1st pick, you get 2nd and 3rd picks in 1v1 games`, score: 'a'},
			{label: "Using last regular pick + initial back up picks to verify if opponent is in the region and also to get at least one pick there", score: 'a'},
			{label: "Calculating net income gain", help: `If you lose 5 income while opponent loses 7 income, then during the turn you gain (-5)-(-7)=2 net income. If you gain 4 income, but opponent gains 5 income, you lose 4-5=-1 net income.`, score: 'a'},
			{label: "Understanding positional situations during picking", help: `If both you and opponent get a pick nearby and you both can counter each other's bonus, then it's a stalemate. If you get one pick near opponent's 2 picks and neither of you can get either of bonuses, you're winning because only one of your picks got stalled, while opponent has 2 of his picks stalled`, score: 'a'},
			{label: "Managing stack preservation.", help: `If you lose 100% of your stack, you're losing more armies than opponent does, so you need to look for ways to ensure that your stack does not get destroyed`, score: 'a'},
			{label: "Concentrated effort attacks", help: `Going 100% against specific target`, score: 'a'},
			{label: "1 army tapping", help: `You can take down 5 defending armies with 8 army attack, but if you lose 1 army attack first, you can take 5 defending armies with only 7 armies like this: 1vs5+6vs4.`, score: 'a'},
			{label: "Understanding rounding mechanics", help: `For example 5 defending armies kill 5*0.7=3.5=4 armies, so for each defense of 10x+5 armies you kill 0.5 additional armies`, score: 'a'},
			{label: "Choosing between attacking from one place versus attacking from multiple areas", help: `If you attack same area multiple times, you lose additional armies, because same defending armies get to defend multiple times`, score: 'a'},
			{label: "Knowing how to increase pressure", help: `The more territories opponent has to defend, the easier time you have breaking his bonuses`, score: 'a'},
			{label: "Breaking bonus versus fully taking bonus", help: `To break bonus you only need to take one territory, to fully take bonus you need all the territories. Breaking bonus is far easier in most cases than fully taking it`, score: 'a'},
			{label: "Determining opponent's most likely to defend area", help: `Opponent is most likely to defend his least guarded, or most valuable bonus, so going for less important area can increase your chances of successful attack`, score: 'a'},
			{label: "Ability to minimize bonus weaknesses through expansion", help: `If bonus is countered by territory X, it makes sense to expand to a bonus with territory X in order to prevent opponent from getting there first`, score: 'a'},
			{label: "Ability to infiltrate bonus region", help: `If you cross the bottleneck before opponent can secure it, he becomes less capable of stalling you`, score: 'a'},
			{label: "Making initial starting bonus take over plan", score: 'a'},
			{label: "Using custom scenario or other means to plan personal moves", score: 'a'},
			{label: "Giving opponent false expectations", help: `If you deploy most your income to same bonus for an extended amount of time, opponent might get used to it, so then you can use that as opportunity to do something else`, score: 'a'},
			{label: "Evaluating different expansion plans", help: `For example on 1v1 ladder template these plans can be: +5 income bonus in 2 turns; two +3 income bonuses in 2 turns; +6 income bonus in 2 turns; +4 and +3 income bonuses in 2 turns; targeting safe income bonuses surrounded by bottleneck or wastelands`, score: 'a'},
			{label: "Tracking opponent's income", help: `If opponent deployed +15 income one turn and only +8 income next turn, it means he used +7 income for expansion elsewhere or he's moving towards ambushing you. After opponent deploys low long enough, it's safe to assume that he has taken additional bonuses and has even higher income`, score: 'a'},
			{label: "Tracking whether opponent successfully takes any territories and gains a card piece", score: 'a'},
			{label: "Carefully managing card use and card piece gain in order to avoid hitting card limit", score: 'a'},
			{label: "Not defending territories which you don't have to defend", help: `For example you have a territory in a bonus with a wasteland and opponent is near. In most cases you should not defend that territory, unless it's the last remaining territory in the region`, score: 'a'},
			{label: "Determining the most likely starts for the opponent", help: `Based upon bonus value or best expansion plans`, score: 'a'},
			{label: "Launching ambush attacks", help: `Move towards opponent while being hidden by fog`, score: 'a'},
			{label: "Understanding circumvention maneuver", help: `You have territory A and border opponent's bonus' territory B. Right now it's stalemate. You can move around territory B until you get into positional advantage and become able to break a bonus`, score: 'a'},
			{label: "Knowing fall back maneuver", help: `You can no longer hold your position, so you transfer your defending armies towards a spot where you could amass more armies`, score: 'a'},
			{label: "Knowing hunt down maneuver", help: `You identify opponent's stacks which keep running away from your bigger stacks, so you keep attacking them with your stacks with first orders until the stacks get destroyed`, score: 'a'},
			{label: "Understanding retaking maneuver", help: `Opponent has a big stack on territory X, which you cannot stop, but you can deploy small army stacks around it and after using some delay moves let opponent take territory Y somewhere else, while you take now empty territory X for yourself`, score: 'a'},
			{label: "Knowing evacuation maneuver", help: `Opponent is to take out your stack and you got no areas to transfer to, so you take neutral territory instead`, score: 'a'},
			{label: "Understanding dodge maneuver", help: `Instead of transferring your stack away, you move sideways from opponent's bigger stack with intention to be able to defend your stack better next turn`, score: 'a'},
			{label: "Knowing delayed explosion maneuver", help: `You have deploy an army stack in territory X, then use some delay orders and issue many tiny attacks to all of opponent's territories followed by one big attack at the end. The likely scenario is that opponent already hit you from all directions, lost all his armies and you can take all his undefended territories now. If you issue the big attack first, you run a risk of not having enough surviving armies for the little attacks`, score: 'a'},
			{label: "Understanding surprise hit maneuver", help: `You expect opponent to take neutral territory X, so you attack it with extra armies first to prevent opponent from taking it`, score: 'a'},
			{label: "Being able to deploy all the expansion armies in one go", help: `For example 12 armies takes 2 army neutral, then it becomes 10 and takes 4 army mini wasteland and becomes 6, then it takes two 2 army neutrals in one go. For territories which will be taken last, full amount of needed armies is used, for territories which will be taken before that, territory cost is used instead`, score: 'e'},
			{label: "Calculating needed deploying effort", help: `To take bonus X you'll need Y armies and you got Z left overs, so the total effort cost will be Z-Y`, score: 'e'},
			{label: "Calculating income per effort ratio", help: `Bonus income divide by total effort cost`, score: 'e'},
			{label: "Using bonus measurement methods", help: `Like income per cost, income per effort) while dealing with bonuses which already have an opponent in them. (Opponent could deploy income to them`, score: 'e'},
			{label: "Using custom scenario or another method to precisely model opponent's most likely expansion options", help: `Which territories with how many armies opponent has during any given turn for any likely plan`, score: 'e'},
			{label: "Being able to force opponent to defend an already broken bonus", help: `Once you become able to retake full bonus, opponent might get forced to defend it with additional force`, score: 'e'},
			{label: "Preventing opponent from being able to take your already broken bonus in one turn", help: `defensive version of previous point`, score: 'e'},
			{label: "Syncing your moves/card use with your move order", help: `For example if you have 2nd move order now, you move to territory X and next turn you use your 1st order to issue a deadly 1st order attack`, score: 'e'},
			{label: "Identifying opponent's use of cards", help: `If you were supposed to have 1st order, but opponent moved first, he used order priority card. If you had sufficient amount of delay moves, but opponent still got last order, he might have used an order delay card`, score: 'e'},
			{label: "Keeping track of when opponent will be able to play the next card", help: `Applies to all cards in game. If opponent has multiple cards, it means he can play them any time, even if he just used one of that card`, score: 'e'},
			{label: "Identifying good situations for opponent to use his cards", help: `If opponent has 2nd move order, he might use order priority card, if he's not defending a bonus, he might have blockaded a territory in it, which you haven't seen yet`, score: 'e'},
			{label: "Optimizing delay moves", help: `Precisely identify how many move orders opponnent will have, which move order (1st or 2nd) he has and based on this information find better ways to use some of your leftovers`, score: 'e'},
			{label: "Being able to create artificial delay moves", help: `For example using 1 army transfers among defending stacks, using 1 army taps on opponent's stacks or using 1 army transfer as your first order when you have 1st move order`, score: 'e'},
			{label: "Maximizing defensive/offensive potential", help: `For example 2 defending armies kill 1 army → 50% kill ratio and 5 defending armies kill 4 armies → 80% kill ratio. The idea is to deploy +1 as long as either while defending or attacking that 1 added army also increases amount of killed armies by 1 as well`, score: 'e'},
			{label: "Calculating army net gain", help: `For example my income is 20, opponent has 25 income, I kill 50 armies while opponent only kills 40 armies. Net army gain is 20-25+50-40=-5+10=5. Consistently sustained army net gain is more important than income net gain!`, score: 'e'},
			{label: "Calculating long term defending stack survival", help: `I got 5 income, opponent has 6 income. His defending stack is 10, my attacking stack is 15. 1st turn: (10+6)*0.7=16*0.7=11 attackers killed, (15+5)*0.6=20*0.6=12 defenders killed. 2nd turn: (16-12+6)*0.7=10*0.7=7 attackers killed, (20-11+5)*0.6=14*0.6=8 defenders killed. 3rd turn: (10-8+6)*0.7=8*0.7=6 attackers killed, (14-7+5)*0.6=12*0.6=7 defenders killed. 4th turn: (8-7+6)*0.7=7*0.7=5 attackers killed, (12-6+5)*0.6=11*0.6=7 defenders killed. by the 5th turn Defender has lost his defended territory`, score: 'e'},
			{label: "Detecting forced stalemate", help: `For example both players have 7 income. Attacker has 4 armies, defender has 3 armies. If defender loses his territory, he loses a bonus. 11*0.6=6.6=7, 10*0.7=7 armies. Both players can kill and deploy 7 armies, so as long as attacker keeps attacking, he forces a stalemate. Let's say defenders decides to use +1 deploy somewhere else for expansion. 1st turn: Attacker kills 7, while defender kills 9*0.7=6. 2nd turn: Attacker kills (11-6+7)*0.6=12*0.6=7 armies, defender kills (9-7+7)*0.7=9*0.7=6 armies. 3rd turn: Attacker kills (12-6+7)*0.6=13*0.6=8 armies, defender kills (9-7+7)*0.7=9*0.7=6 armies. 4th turn: Attacker kills (13-6+7)*0.6=14*0.6=8 armies, defender kills (9-8+7)*0.7=8*0.7=6. By the 5th turn defender has lost his territory. Because of this defender cannot deploy at any given time any of his armies elsewhere but to his defended territory, therefore attacker can after some time can issue any other activity, like take a bonus and go threaten defender elsewhere and there's nothing that defender can do about it`, score: 'e'},
			{label: "Understanding expansion cancellation maneuver", help: `If you know that opponent will take neutral territory X with bare minimum required armies, you can out delay your opponent and take that same territory with bare minimum required armies as well`, score: 'e'},
			{label: "Knowing the distraction maneuver", help: `On turn X, you appear at opponent's border in territory Y. Opponent probably will defend hard and hit that territory. In the meantime you were moving a large stack towards a different opponent's area. During next turn you start to border opponent at another region in territory Z. Now opponent has a useless stack in X, didn't do much and is unable to defend against Z`, score: 'e'},
			{label: "Knowing the sidestepping maneuver", help: `Territory A connects to B and C. B connects to D and C connects to D. You have A, while opponent has C and D. You need to take either C or D to break opponent's bonus. Your stack is in A and opponent's stack is in C. When you have 2nd move order, you move to B, while opponent's stack remains in C. Next turn you use your 1st move order to break D. Because opponent's stack is in C and he has 2nd move order, he cannot come in time to protect his bonus`, score: 'e'},
			{label: "Knowing the Trojan Bonus technique", help: `You have A and B territories, opponent has C territory, all territories interconnect. A belong to bonus X, C belongs to bonus Y. Y bonus is more valuable than X bonus. You make a big stack in B, use delay move orders, allow opponent to break X and on your last move order take now empty C, thus breaking Y bonus. Because Y was worth more income, the opponent is the one who lost the income, not you`, score: 'e'},
			{label: "Understanding surprise transfer maneuver", help: `Opponent with his stack is turn by turn taking a trail of your undefended territories. At some point he will have to take territory X. Because you're not defending opponent has low amount of initiative to deploy something himself. In the meantime in territory Y, which is behind X, you were amassing a big stack. When opponent is about to attack X, you use 1st move order and transfer from Y to X. Opponent hits your stack and loses his whole stack`, score: 'e'},
			{label: "Knowing tiny counter attack maneuver.", help: `Similarly to previous point, you transfer armies to X territories. The difference this time is that you also have some armies in X already, or just deployed them there, so after some delay moves you can retake opponent's territory, because his stack by that time has already suicided into your transferred stack`, score: 'e'},
			{label: "Understanding The desperado maneuver", help: `You have territory A and C, opponent has territory B. B connects to A and C, A doesn't connect to C. A belongs to your bonus. C has some of your armies. Opponent has a big stack in B and threatens to break your bonus. You use your 1st move order and suicide your C stack into B, because it cannot be transferred into A. Because of this you enable your A stack to survive`, score: 'e'},
			{label: "Knowing the rap setter maneuver", help: `Opponent cannot defend against you, so he’s going to try to dodge you. You hit opponent’s expected destination with a heavy first order attack. You make some delay orders and attack the original opponent’s position with small attack. Opponent will hit your trap and lose his stack and after that if possible you should clear his presence in that region`, score: 'e'},
			{label: "Knowing how to vaporize your stack", help: `You got a stack surrounded by opponents’ armies and you see no good use for your stack. If your stack gets destroyed you lose 100% of it and only kill 70% in return, therefore you keep using 1 army taps until your stack is gone. This way you exchange your armies with opponent at 1:1 rate`, score: 'e'},
			{label: "Having realistic expectations for opponents attacks/defenses/ambushes", help: `You should consider what opponent knows or suspects about you. You should also understand opponent’s situation. Based on these factors you should be able to predict his decisions with high accuracy and act accordingly`, score: 'e'},
			{label: "Opponent’s analysis based on his previous game examples", help: ``, score: 'e'},
			{label: "Expecting opponent’s decisions based on psychological analysis", help: `For example opponent could defend his least defended spot the most or he could defend everything evenly, both of which are weak to concentrated 100% attack against most reinforced spot at the time. Opponent also tends to reinforce spots closest to his other spots, so you can break bonuses by hitting more remote areas. Opponent could get used to your attack pattern, if you hit him in same territory twice, on 3rd turn you can hit another territory by surprise`, score: 'e'},
			{label: "Knowing precise attacking/defending numbers/ratios", help: `Here’s a list of important numbers (y=defending armies, x=attacking armies, result is always rounded up):
a) Minimum defense: y=0.6x+1
b) Equal loses while defending: y=0.8571x
c) Equal loses while attacking: x=1.1667y
d) 100% defenders killed: x=1.6667y
e) 100% attackers killed: y=1.4286x
f) Successful counterattack (1 army stand guard version): y=1.04615x+0.49231
g) Successful counterattack (simple version): y=1.04615x
h) Bare minimum counterattack (1 army stand guard version): y=0.97248x+0.58716
i) Bare minimum counterattack (simple version): y=0.97248x

(All numbers have been found through use of mathematical equations, full formulas will be available in strategy guide at a later date)`, score: 'e'},
			{label: "Mapping all potential starting pick strategies using custom scenario or another tool", help: ``, score: 'e'},
			{label: "Evaluating picks based upon their functionality", help: `How many regions are covered by this pick, how many picking strategies include this pick, what’s the bonus cost, how soon the bonus will payback, what are positional advantages or disadvantages of the bonus`, score: 'e'},
			{label: "Determining the most important bonuses based upon previous point", help: ``, score: 'e'},
			{label: "Making back up plans/picks for the worst case scenario where the most important pick or picks could get stolen by the opponent", help: ``, score: 'e'},
			{label: "Applying sneaky picking strategy to guarantee presence in X region", help: `Let’s say that opponent is likely to make 5 picks in region X and you want presence there, yet you want to dedicate your first few picks elsewhere. You can make 3 picks elsewhere and put 4th, 5th, 6th, 7th, 8th pick in the region X, at least one of those picks is going to clash with opponent’s 4th pick as his first 3 picks cannot steel everything. If opponent pushes your 4th (7th ordered) pick too, it has no other place to go but to 8th, spot, which as result guarantees you at least one pick in 5 picks area`, score: 'e'},
			{label: "Knowing advanced sneaky pick strategy", help: `It’s similar to original variation, except instead of using something like 4th - 8th pick, you use 4th, 5th, 6th, 7th, 9th picks to guarantee yourself presence. If you lose your 7th pick, your 4th start goes to 8th pick and your 5th start will 100% be chosen before opponent’s 5th,, because he already had 1st move order on 4th start, so now it’s your turn to have 1st move for your 5th start. If you get your 7th pick, your 5th start goes to 8th start which is somewhere else, therefore opponent’s 5th start is unobstructed and this way you guarantee yourself at least 1 pick in opponent’s region. Both this and previous point can apply to any 2+ pick region`, score: 'e'},
			{label: "Creating branching picking strategy", help: `What happens if you lose 1st pick? What happens if you lose 2nd pick? What happens if you lose 2nd and 3rd pick and so on… The goal of this approach is to ensure low odds of bad start due to some stolen picks`, score: 'e'},
			{label: "Adapting to opponent’s play style", help: `For example, if Opponent only goes for delayed attacks, attack/dodge him with early move orders. If opponent only makes concentrated attacks, use many tiny attacks against him. If opponent only cares about breaking your bonuses or defending bonuses which are not broken yet, try to fully take opponent’s already broken bonuses`, score: 'e'},
			{label: "Knowing when to expand towards the opponent and when to expand away from him", help: `Seeing many turns ahead of how much income opponent stand to gain if unobstructed and how much income you have to gain. If opponent has more income than you and fighting him is not an option, you should generally expand away from the opponent`, score: 'e'},
			{label: "Ability to play competitively while having less income than opponent", help: `Finding means to stabilize the situation and turn things to your favor`, score: 'e'},
			{label: "Being able to use multiple different picking/fighting/expanding strategies and switching them around to make opponent unable to predict your decisions based on current or previous games", help: ``, score: 'e'},
			{label: "Using same playing approach for a while just to switch it at a convenient moment to catch opponent off guard", help: ``, score: 'e'},
			{label: "Ability to successfully combine all of the above points", help: ``, score: 'e'},
		]},
		{name: 'Various Settings', items: [
			{label: "Using history to determine opponent’s stack size on heavy/dense/complete fog", help: `If you lose 100% of your X attacking armies, opponent has at least X/0.7 defending armies. If you lose 8 attacking armies out of 10, opponent has 8/0.7=11 or 12 defending armies; 10 attacking armies kill 10*0.6=6 armies, so now opponent’s stack has 11-6=5 or 12-6=6 armies.`, score: 'a', subcat: 'Fog Settings'},
			{label: "Setting of false alarm on dense or light fog", help: `Moving towards opponent with only bare minimum attacks, like 3vs2 attacks`, score: 'i', subcat: 'Fog Settings'},
			{label: "Setting false expectations on light or dense fog", help: `For example deploying all armies without attacking neutrals and only attacking neutrals when you have piled up enough armies to successfully take bonus in one go, or taking a neutral territory which enables you to take a bonus in one turn, but instead of doing that next turn attacking opponent at full force. The point of these is to make opponent think that you’re not going to attack him hard or are not going to defend with heavy force while in the mean time that’s exactly what you’re doing or vice versa`, score: 'e', subcat: 'Fog Settings'},
			{label: "Using history to remember where wastelands are", help: ``, score: 'b', subcat: 'Fog Settings'},
			{label: "Setting false neutrals on complete fog", help: `Taking neutral territory and then leaving permanent amount of armies which is equal to supposed neutral amount. This way you’ll know if opponent takes it, but opponent won’t know if you have that territory`, score: 'e', subcat: 'Fog Settings'},
			{label: "Using expected neutral territory costs to detect incorrect leftover amount on complete fog", help: `This almost always means that you just took opponent’s territory and he knows that you’re near him`, score: 'a', subcat: 'Fog Settings'},
			{label: "Using pick conflicts to determine move order during light or dense fog games", help: `Find there your and opponent’s same order pick clashes. If it’s 1st, 3rd, 5th pick and so on and you won the pick, you had 1st move order during picking. If same happens with 2nd, 4th, 6th and so on pick, you had 2nd move order. If opposite happens, then instead of 1st move order you had 2nd move order or vice versa. Keep in mind that the order is based not on actual pick order but the order in which you got your final picks`, score: 'e', subcat: 'Fog Settings'},
			{label: "Determining the areas where opponent can realistically be", help: `The more time passes, the more territories the opponent should take, so tiny clusters of fogged territories become less likely to host opponent`, score: 'i', subcat: 'Random Distribution'},
			{label: "Expanding with intent to maximize map exploration", help: `Moving towards centers of fogged areas or towards best starting bonuses`, score: 'i', subcat: 'Random Distribution'},
			{label: "Using binomial coefficient to determine likelihood of opponent stating in X bonus", help: `https://en.wikipedia.org/wiki/Binomial_coefficient`, score: 'e', subcat: 'Random Distribution'},
			{label: "Understanding that commander is always worth 7 armies, that other armies defending him die first and that if commander dies, you get eliminated", help: ``, score: 'b', subcat: 'Commander'},
			{label: "Using commander for efficient expansion", help: ``, score: 'i', subcat: 'Commander'},
			{label: "Finding the safest place to hide commander from opponent", help: ``, score: 'b', subcat: 'Commander'},
			{label: "Putting priority on opponent’s commander", help: ``, score: 'i', subcat: 'Commander'},
			{label: "Finding effective means to use commander in fighting opponent", help: ``, score: 'a', subcat: 'Commander'},
			{label: "Navigating the map while avoiding unnecessary transfers", help: ``, score: 'b', subcat: 'Multi Attack'},
			{label: "Finding shortest path to break maximum amount of opponent’s bonuses", help: ``, score: 'i', subcat: 'Multi Attack'},
			{label: "Casting a multi attack net", help: `Territories connect like this: A – B – C – D – E. Opponent is threatening to take them all. You can launch one attack from A to E and another attack from E to A, this way you maximize the odds of successfully retaking lost territories if one of your 2 stacks runs into trouble`, score: 'a', subcat: 'Multi Attack'},
			{label: "Taking the long route to circumvent opponent’s most well defended territories", help: ``, score: 'i', subcat: 'Multi Attack'},
			{label: "Finding and defending most bottleneck like territories", help: `Minimize the odds of opponent braking high amount of bonuses`, score: 'i', subcat: 'Multi Attack'},
			{label: "Leaving tiny stacks within bonuses to counter opponents who try to take all the bonuses with minimum required amount of armies", help: ``, score: 'a', subcat: 'Multi Attack'},
			{label: "Performing \"train stopping\" maneuver", help: `You determine area where opponent will most likely go through and take it first order. Then you make some delay move orders and issue later orders for your stack. Opponent will most likely hit your big stack first and be stopped before doing any heave damage`, score: 'e', subcat: 'Multi Attack'},
			{label: "Using attack + transfer maneuver(s) to get extra delay moves", help: ``, score: 'i', subcat: 'Multi Attack'},
			{label: "Choosing likely picks in advance before clicking “begin” button", help: ``, score: 'i', subcat: 'No Luck Cycle Move Order'},
			{label: "Lowering total pick amount to lower picking speed", help: ``, score: 'a', subcat: 'No Luck Cycle Move Order'},
			{label: "Determine shortest mouse/hand (for phone) path to make all the picks as fast as possible", help: `This includes begin and commit buttons`, score: 'i', subcat: 'No Luck Cycle Move Order'},
			{label: "Determining whether to go for slow or fast approach", help: `Fast approach is good for getting 1st pick, 3 picks of 5 first picks, 5 picks of first 9 picks and also getting 1st move during 2nd turn. Slow approach is good for getting 2 picks out of first 3 picks, 4 picks out of first 7 picks and also getting first order during 1st turn.`, score: 'e', subcat: 'No Luck Cycle Move Order'},
			{label: "Ability to quickly adapt to random warlords or cities distributions", help: ``, score: 'a', subcat: 'No Luck Cycle Move Order'},
			{label: "Not running out of armies on 0 base income games", help: ``, score: 'i', subcat: 'Base Armies per Turn'},
			{label: "Calculating at what point income per territory value exceeds base income value", help: ``, score: 'b', subcat: 'Extra Armies per Territory'},
			{label: "Treating territories like they were a bonus while dealing with the opponent", help: ``, score: 'i', subcat: 'Extra Armies per Territory'},
			{label: "Finding most efficient ways to avoid hitting army cap", help: `For example: expanding, suiciding stacks into opponent/wastelands`, score: 'a', subcat: 'Army Cap'},
			{label: "Determining whether opponent has hit army cap", help: ``, score: 'i', subcat: 'Army Cap'},
			{label: "Preventing opponent from eliminating his stacks, so that his income stays low", help: `Basically not targeting his stacks and keeping your stacks away from him`, score: 'i', subcat: 'Army Cap'},
			{label: "Keeping 1 army neutral on 1 army stand guard setting for repeated 1 army taps", help: `This helps to kill off unnecessary armies`, score: 'a', subcat: 'Army Cap'},
			{label: "(all excluded)", help: `In https://www.warzone.com/Forum/664334-skill-evaluation-phakh-gokhn#PostTbl_1304219 scoring seems way too high when there's Game > Analyze attack`, score: 'none', subcat: 'Luck Settings'},
			{label: "Ability to adapt to non standard kill rates", help: ``, score: 'i', subcat: 'Kill Rates'},
			{label: "Knowing how to play when offensive kill rate is higher than defensive kill rate", help: `Hunting opponent’s stacks with first moves, avoiding delay moves`, score: 'i', subcat: 'Kill Rates'},
			{label: "Finding good uses for transfer only", help: `For example transferring to risky spot when opponent has first move`, score: 'a', subcat: 'Transfer/Attack Only'},
			{label: "Finding good uses for attack only", help: `For example you’re not sure if opponent will take you X territory and you don’t to split your armies without a need`, score: 'e', subcat: 'Transfer/Attack Only'},
			{label: "Finding shortest transfer path", help: ``, score: 'b', subcat: 'Local Deployments'},
			{label: "Ability to expand efficiently", help: `For example you target furthermost territories first`, score: 'i', subcat: 'Local Deployments'},
			{label: "Knowing when to expand to bonuses with wastelands", help: ``, score: 'a', subcat: 'Local Deployments'},
			{label: "Ability to expand towards opponent", help: `If you expand away from him, it will take longer and longer for your newly reached bonuses to become useful`, score: 'a', subcat: 'Local Deployments'},
			{label: "Foreseeing incoming unfavorable changes", help: `On local deployment settings, situations tend to change slowly, so if each turn situation is getting a bit worse, you must react to it before situation gets to bad`, score: 'a', subcat: 'Local Deployments'},
			{label: "Properly timing transfer reinforcement", help: `It often takes multiple turns for initial transfer to travel all the way to the front, so if you just keep transferring in same direction continuously, you risk achieving over kill in one front area and a critical army shortage in another`, score: 'e', subcat: 'Local Deployments'},
			{label: "Properly timing attacks to break stalemates", help: `If you got 1st move order, you hit opponent’s stack before he can attack or run/transfer to your own stack if you’re in critical condition. If you got 2nd move order perhaps you wait or hit 2 stacks at once as only one of them can be transferred to during opponent’s first order`, score: 'a', subcat: 'Local Deployments'},
			{label: "Dealing with or avoiding stalemates/bottleneck stand offs", help: ``, score: 'e', subcat: 'Local Deployments'},
			{label: "Maintaining continuity of your controlled region and disrupting opponent’s regions’ continuity", help: `2 disjointed regions are weaker than 1 united region`, score: 'e', subcat: 'Local Deployments'},
			{label: "Using tiny low army attacks to take opponent’s undefended territories to see what lies behind the front line", help: `Opponent could be hiding a surprise stack behind fog`, score: 'i', subcat: 'Local Deployments'},
			{label: "Effective creation and use of 1 army transfer delay moves", help: ``, score: 'i', subcat: 'No Split'},
			{label: "Avoiding formation of over kill stacks", help: `Stacks with way more armies than necessary`, score: 'i', subcat: 'No Split'},
			{label: "Finding optimal expansion options", help: `For example both 3 and 4 territory bonuses can only be taken in 2 turns if you start with only one pick in them`, score: 'a', subcat: 'No Split'},
			{label: "Clearing opponent’s stack trail", help: `If you out-delay opponent, you can let him move his stack and then retake his previous territory with 2 army attack, if you can continuously out delay opponent, you can keep his presence permanently down to 1 territory`, score: 'a', subcat: 'No Split'},
			{label: "Finding way to increase held territory count within opponent’s territory", help: ``, score: 'a', subcat: 'No Split'},
			{label: "Performing trailer maneuver", help: `For example you border opponent. You deploy very little near his border and then transfer to same place a big amount of armies during first move order. After that you make some delay moves and issue attack from your small stack. Firstly this helps to minimize odds of opponent performing a successful counter attack or you suiciding into opponent’s massive transfer/deploy. Secondly it prevents opponent from sneakily retaking your territory from another spot. Thirdly it allows you to keep your main stack closer to other more important areas`, score: 'e', subcat: 'No Split'},
			{label: "Quickly finding bonuses with the changed value", help: ``, score: 'b', subcat: 'Overridden Bonuses'},
			{label: "Finding bonuses which bonus icon is not directly shown on the map", help: `Use map page, or click a territory and find to which bonuses it belongs or use statistics search`, score: 'b', subcat: 'Overridden Bonuses'},
			{label: "Understanding difference between various bonus systems", help: `When X is territory amount Y is the income, these systems could be something like: Y=X-1; Y=X; Y=X+1. Some systems make small bonuses more valuable, some make bigger bonuses better, some make certain size bonuses useless and so on...`, score: 'a', subcat: 'Overridden Bonuses'},
			{label: "Understanding where and how to observe game’s custom scenario or how to make your own custom scenario", help: ``, score: 'b', subcat: 'Custom Scenario'},
			{label: "Efficiently using first tier of armies", help: `If first 10 armies cost 1 gold and next 10 armies cost 2 gold and so on, it’s best to deploy 1 gold armies as deploying high amounts of them can be expensive`, score: 'i', subcat: 'Commerce Games'},
			{label: "Saving up high amount of gold for a surprise attack", help: `It’s risky because due to army cost tiers you can actually end up losing income/armies in the process`, score: 'a', subcat: 'Commerce Games'},
			{label: "Knowing how to place a city", help: ``, score: 'b', subcat: 'Commerce Games'},
			{label: "Finding best location to place cities", help: `Safe, far from opponent, potentially a bottleneck…`, score: 'b', subcat: 'Commerce Games'},
			{label: "Deciding whether or not to stack cities on top of each other", help: `If you cannot protect a territory in near future, don’t place cities there, even if it’s cheap`, score: 'i', subcat: 'Commerce Games'},
			{label: "Deciding between expanding, building cities or attacking opponent", help: `Use income per cost ratios and etc...`, score: 'a', subcat: 'Commerce Games'},
			{label: "Keeping higher territory amount", help: `More territories means cheaper cities`, score: 'i', subcat: 'Commerce Games'}
		]},
		{name: 'Various Cards', items: [
			{label: "Understanding how much armies will be given for a reinforcement card worth a progressive amount of armies", help: `For example its value is tied to amount of turns passed`, score: 'i', subcat: 'Reinforcement Card'},
			{label: "Using reinforcement’s value to determine how many territories opponent has", help: `When value is tied to territory count`, score: 'i', subcat: 'Reinforcement Card'},
			{label: "Deciding whether it’s worthwhile to get reinforcement", help: `Taking territories for card pieces costs armies and could result in a failed defense or missed offensive opportunity`, score: 'a', subcat: 'Reinforcement Card'},
			{label: "Deciding between using reinforcement immediately or saving it for a later surprise or potential better use", help: ``, score: 'i', subcat: 'Reinforcement Card'},
			{label: "Checking", help: ``, score: 'b', subcat: 'Order'},
		]}
	];

	function makeForm() {
		const criteriaList = document.getElementById('criteriaList');
		let foundSubcats = {};
		let prevI = 0;

		for (let cat of criteria) {
			const catArea = document.createElement('div');
			const heading = document.createElement('h2');
			const itemsContainer = document.createElement('ol');
			let itemsSubContainer;

			heading.innerText = cat.name;
			itemsContainer.start = prevI + 1;
			catArea.appendChild(heading);

			for (let item of cat.items) {
				prevI++;

				if (item.subcat) {
					if (!foundSubcats[item.subcat]) {
						foundSubcats[item.subcat] = true;
						const subcatHeading = document.createElement('h3');
						subcatHeading.innerText = item.subcat;
						itemsContainer.appendChild(subcatHeading);
						itemsSubContainer = document.createElement('ol');
						itemsSubContainer.start = prevI;
						itemsContainer.appendChild(itemsSubContainer);
					}
				}

				const line = document.createElement('li');
				const checkbox = document.createElement('input');
				checkbox.type = 'checkbox';

				line.appendChild(checkbox);
				line.appendChild(document.createTextNode(item.label + ' '));

				if (item.help) {
					const helpBtn = document.createElement('input');
					const helpArea = document.createElement('div');

					helpBtn.type = 'button';
					helpBtn.value = '?';
					helpBtn.onclick = () => {
						if (helpArea.innerHTML) {
							helpArea.innerHTML = '';
						}
						else {
							if (item.help.match(/^https?:/)) {
								const a = document.createElement('a');
								a.target = 'blank';
								a.href = item.help;
								a.innerText = item.help;
								helpArea.appendChild(a);
							}
							else {
								helpArea.innerText = item.help;
							}
						}
					};

					line.appendChild(helpBtn);
					line.appendChild(helpArea);
				}

				(itemsSubContainer || itemsContainer).appendChild(line);
			}

			catArea.appendChild(itemsContainer);
			criteriaList.appendChild(catArea);
		}
	}

	function calcScore() {
		const catAreas = document.getElementById('criteriaList').children;
		let score = 0;

		for (let i = 0; i < catAreas.length; i++) {
			const catArea = catAreas[i];
			const checkboxes = catArea.querySelectorAll('input[type="checkbox"]');
			const cat = criteria[i];

			for (let j = 0; j < checkboxes.length; j++) {
				const checkbox = checkboxes[j];
				const item = cat.items[j];

				if (checkbox.checked) {
					score += scoring[item.score].score;
				}
			}
		}

		console.log(score);
	}

	document.onreadystatechange = (e) => {
		if (document.readyState == 'complete') {
			makeForm();
			document.forms[0].onsubmit = calcScore;
		}
	};
})();