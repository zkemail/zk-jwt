// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract JwtAuthGroth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay  = 9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1  = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2  = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1  = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2  = 10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 20339949882325088124254203258119954178031904040667916879727575054364717477206;
    uint256 constant deltax2 = 13412950151809245307830438043214245025934527933644785937270029753540517372782;
    uint256 constant deltay1 = 2526813238220015177675140851984938759296378371409788079491143456919604215058;
    uint256 constant deltay2 = 2949808002113600242121094468136870027770963899429097764727844584193997740102;

    
    uint256 constant IC0x = 9376496373014311571210246487288461138151429271987024375631124481964272262769;
    uint256 constant IC0y = 5016090247628622248706479728244979786121102963284123481391731131480364516943;
    
    uint256 constant IC1x = 14865267262950089874266377057581172714741793072377248374028727690215357036657;
    uint256 constant IC1y = 16954965070037172893786864711048929368163978978229246335372115628142213378594;
    
    uint256 constant IC2x = 16966119838156000630754580698452082029603932710779732470068831670932650868998;
    uint256 constant IC2y = 18371339671564207332335439518653269978649712926257804727838019392599939162909;
    
    uint256 constant IC3x = 12060030339050587397979828737146963745594150931139426422147621070271169722523;
    uint256 constant IC3y = 5640763865545044856027362564420873136921071031546626470695156030677411776323;
    
    uint256 constant IC4x = 19052057738150117829571271718688269029818976942429028455363832008764329284688;
    uint256 constant IC4y = 4887463334862420712708198105277510525428025873954222076152740484518302095476;
    
    uint256 constant IC5x = 1781086744324982537593762236998965175975641709700342402625960272119084292231;
    uint256 constant IC5y = 21599338391283007779937020454659769303624319362659082252057055158916824057719;
    
    uint256 constant IC6x = 8385720025081534326440141732278111783586112998739686006094315903372943782783;
    uint256 constant IC6y = 7009638785879715067285775141705471134246785756976654596073968112869283657901;
    
    uint256 constant IC7x = 8740754840548942237804047113676388981431731067437471944203631030058582242590;
    uint256 constant IC7y = 17105282088874034202415567947960552873418190615151104590048519855961261433850;
    
    uint256 constant IC8x = 6501223228103290751603355560504844568435832821747207363767846391891805463886;
    uint256 constant IC8y = 12949140834446918569247715378026286451892272872282300612595831613310346024126;
    
    uint256 constant IC9x = 10556572487509354402048624245424821473949061830035313781486894217168853892805;
    uint256 constant IC9y = 14172000770499814348751571302801118121778556141316777379523760606660084725249;
    
    uint256 constant IC10x = 9076595456284501611167457313855141401384803150400429786850120711538336204529;
    uint256 constant IC10y = 7293845495073170344349121908094660163697396554978010777187514688300459267953;
    
    uint256 constant IC11x = 13400666242721896745934470128572074278055406864235134959147105007794234467499;
    uint256 constant IC11y = 6438967242725026239136600440505422502123787761191284189270708789992420233556;
    
    uint256 constant IC12x = 17265896900576366482669099232220698295831485441662483559088446170539564410944;
    uint256 constant IC12y = 10327367649250536174018847301614884726342955864637361156895437248308266368999;
    
    uint256 constant IC13x = 13862088196944591092025628425899681719837882713079053805280315056178280865588;
    uint256 constant IC13y = 4310444378968104941372377097272305470397955485000745909089043075968148422134;
    
    uint256 constant IC14x = 15612225976565194555643192295044411796977386600692084720150820174756327937022;
    uint256 constant IC14y = 1561034431385823196140791842178347317787463566085746002012166813919763427030;
    
    uint256 constant IC15x = 5325657508682838647858959668473674200940613580540797840510938914390982150019;
    uint256 constant IC15y = 20720779299408904266781479455993518253856140972111824917672604697677738339372;
    
    uint256 constant IC16x = 4707870236663211208963815829352189365350330904199671654085313791913714012028;
    uint256 constant IC16y = 8602292549721921690759543836895216856213784950346834786333741701218388361320;
    
    uint256 constant IC17x = 5767849322030566190499291320629684528314258411471879062899164399371841040336;
    uint256 constant IC17y = 19878199385648079307858218838492397626401244847983247047080672925479410264046;
    
    uint256 constant IC18x = 18827928703479733736624056950223821973856093404395335815681368034679678286447;
    uint256 constant IC18y = 19110146663288553729578431458391118804322723833631406412568772443483749160073;
    
    uint256 constant IC19x = 15981479407127128901851487061855258239683267983497809571173258210764230876770;
    uint256 constant IC19y = 14774320973373749037434780746338713198703628701775097574160135653963635290298;
    
    uint256 constant IC20x = 14904183733319482682065408571109598622522923567198466354963815833914243980140;
    uint256 constant IC20y = 10844066041941903748695939897005057877243187755592953628350847220773487259104;
    
    uint256 constant IC21x = 18480412726374596222432748806876833459242447064186941319567242519001471530668;
    uint256 constant IC21y = 17711965736830433360644120985846595107506935478905123523421448725886178577466;
    
    uint256 constant IC22x = 15630469892114737619037824271059347818496292446497087121890436879579642723683;
    uint256 constant IC22y = 15122374063897299437798512060199237008414376983041729129175550666288242704972;
    
    uint256 constant IC23x = 7199149674052751430868726584624051770566171626693693478301509047955907280591;
    uint256 constant IC23y = 6556567854465986797082386842597189716134915010616533958115253730190963300089;
    
    uint256 constant IC24x = 20559993817397484668547965860815128954181256343295509669466707437089887082660;
    uint256 constant IC24y = 18963696815717272104028780035850096452258689740310849892970087912509561010907;
    
    uint256 constant IC25x = 8955617296124016536713041681033467806367777192341156707084142855157999629645;
    uint256 constant IC25y = 13594254598744488840992404830988862596344030740406222304466808599370261601898;
    
    uint256 constant IC26x = 4048756720029439151842034138046322709965296558911826061915785403391855131925;
    uint256 constant IC26y = 15819938897454241094948722116654849618484289100295717058346748400231489010894;
    
    uint256 constant IC27x = 976424673906320166320018830385598680427938299260714474084373289068672631735;
    uint256 constant IC27y = 2208566050828941572256864331841041177018199363515363458827490570881014561748;
    
    uint256 constant IC28x = 2655816203482257805632954188520021137143344710977543321010249199642094781668;
    uint256 constant IC28y = 6843200120540965961292682066426505688057442120539050746479470513748076960661;
    
    uint256 constant IC29x = 17703176854315273302522602835065911605408256870143803312126436956486129363053;
    uint256 constant IC29y = 21696797401572527290926790241166209606586060296990221988929079311818270431036;
    
    uint256 constant IC30x = 10309933496360358021860933417393424466231682541595418559636942515881183788630;
    uint256 constant IC30y = 7163475630753920981156383854309426286550090734564857235360552121545823327324;
    
    uint256 constant IC31x = 13249776708933918645141618950712865567223538295546127156841796467278853450234;
    uint256 constant IC31y = 3307698083013945776658734251560345768291816021238467222223565169919838464580;
    
    uint256 constant IC32x = 10358820946813800872618635000110859705896765216022858043288865043931235695946;
    uint256 constant IC32y = 19130057517024930769422408811632256998754742664243149077098898150278935267970;
    
    uint256 constant IC33x = 8744585889584258448407524627582308768328137461886814506291712188905288500013;
    uint256 constant IC33y = 3921832436231972808953438847649246514207335100123807562228824058968251309051;
    
    uint256 constant IC34x = 3380902191048158532728811509773583190926888856393464467884253360847580867637;
    uint256 constant IC34y = 6004946907279166984304755974922655705536850881301136412893525341692539265560;
    
    uint256 constant IC35x = 9245010413071580378196486747315596166351124022206471944900897872187365963232;
    uint256 constant IC35y = 5410855844353866812826274917815883919845817912239219442850749620897550249295;
    
    uint256 constant IC36x = 13359482253418509656114195001446001521904252471235591031468297129509410446027;
    uint256 constant IC36y = 18350620459439607931061489641033535044102499626507412249569179095873184811118;
    
    uint256 constant IC37x = 16431035030668008722558538488190197387331578487419913421501209530329347637894;
    uint256 constant IC37y = 2434123978469337834557078276627083096082418483303089431914701639744811140585;
    
    uint256 constant IC38x = 13288573516179126193517168185030457855445118796531632172091283660250804683860;
    uint256 constant IC38y = 18988578676329408132837068310050607337570674226170675692525140641785965522509;
    
    uint256 constant IC39x = 17007343528411833635703301644748296615706323876687868451774663027761281016344;
    uint256 constant IC39y = 5083731877979153059448744739738610996232227832032843973146283534287182221346;
    
    uint256 constant IC40x = 3541364117069740176015503481961697547229759900127167229782399764515531469868;
    uint256 constant IC40y = 15167355602502700282671699441209056466824916469744650042537446345689423301466;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[40] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                
                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))
                
                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))
                
                g1_mulAccC(_pVk, IC28x, IC28y, calldataload(add(pubSignals, 864)))
                
                g1_mulAccC(_pVk, IC29x, IC29y, calldataload(add(pubSignals, 896)))
                
                g1_mulAccC(_pVk, IC30x, IC30y, calldataload(add(pubSignals, 928)))
                
                g1_mulAccC(_pVk, IC31x, IC31y, calldataload(add(pubSignals, 960)))
                
                g1_mulAccC(_pVk, IC32x, IC32y, calldataload(add(pubSignals, 992)))
                
                g1_mulAccC(_pVk, IC33x, IC33y, calldataload(add(pubSignals, 1024)))
                
                g1_mulAccC(_pVk, IC34x, IC34y, calldataload(add(pubSignals, 1056)))
                
                g1_mulAccC(_pVk, IC35x, IC35y, calldataload(add(pubSignals, 1088)))
                
                g1_mulAccC(_pVk, IC36x, IC36y, calldataload(add(pubSignals, 1120)))
                
                g1_mulAccC(_pVk, IC37x, IC37y, calldataload(add(pubSignals, 1152)))
                
                g1_mulAccC(_pVk, IC38x, IC38y, calldataload(add(pubSignals, 1184)))
                
                g1_mulAccC(_pVk, IC39x, IC39y, calldataload(add(pubSignals, 1216)))
                
                g1_mulAccC(_pVk, IC40x, IC40y, calldataload(add(pubSignals, 1248)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            
            checkField(calldataload(add(_pubSignals, 800)))
            
            checkField(calldataload(add(_pubSignals, 832)))
            
            checkField(calldataload(add(_pubSignals, 864)))
            
            checkField(calldataload(add(_pubSignals, 896)))
            
            checkField(calldataload(add(_pubSignals, 928)))
            
            checkField(calldataload(add(_pubSignals, 960)))
            
            checkField(calldataload(add(_pubSignals, 992)))
            
            checkField(calldataload(add(_pubSignals, 1024)))
            
            checkField(calldataload(add(_pubSignals, 1056)))
            
            checkField(calldataload(add(_pubSignals, 1088)))
            
            checkField(calldataload(add(_pubSignals, 1120)))
            
            checkField(calldataload(add(_pubSignals, 1152)))
            
            checkField(calldataload(add(_pubSignals, 1184)))
            
            checkField(calldataload(add(_pubSignals, 1216)))
            
            checkField(calldataload(add(_pubSignals, 1248)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
