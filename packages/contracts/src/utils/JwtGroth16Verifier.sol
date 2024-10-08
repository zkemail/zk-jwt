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

contract JwtGroth16Verifier {
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
    uint256 constant deltax1 = 18939075962544349256250444857523325531478711397189358461104798913741825712529;
    uint256 constant deltax2 = 15109247126290570802355074119841193170418454259438546167502160248419187887158;
    uint256 constant deltay1 = 17922352634892700261210781729509587338888564367950485784425757885739566150977;
    uint256 constant deltay2 = 18502363418448672474646403779995418443808138079533887645179235763892372133866;

    
    uint256 constant IC0x = 14989693056772827914221052480907555856553869483163374655429347727105373980265;
    uint256 constant IC0y = 17123258439336554687093340882775128033200522870276589794001153871012286092137;
    
    uint256 constant IC1x = 21809551117517680227848757884810341125522118458825881806155966146665298816735;
    uint256 constant IC1y = 21877437957582327337776718675712882500675042138185660795880516863618311209510;
    
    uint256 constant IC2x = 13363203193518496239419319689457103365028839831601208274982103888751982160292;
    uint256 constant IC2y = 17366991222254020469684055614796423473046151128002185174472244130373427768171;
    
    uint256 constant IC3x = 6252077137203069317904767930582229151796826341095960591580236048100917693084;
    uint256 constant IC3y = 19564228819102470056756711386623145440569704585649541326135670235070560576139;
    
    uint256 constant IC4x = 19652079766011538286860408343849825288785350353783579036274158854615168144021;
    uint256 constant IC4y = 10818804090933841644751252583877046958060517512401352944036180201515314420280;
    
    uint256 constant IC5x = 12767646248558134348385202181034075508538495727658689840707333645894428504629;
    uint256 constant IC5y = 6330747374055192663142029969789780122686007975639399629972326638924037460253;
    
    uint256 constant IC6x = 11669703117129852413603570622454908789225610552695759497303766562570524187026;
    uint256 constant IC6y = 19581444059501459664328244691102009954160024332793230094316308650729541968419;
    
    uint256 constant IC7x = 12869698202073184275683523618979690360192591591062575369196773485918830811825;
    uint256 constant IC7y = 3451577040060251964166416562620891677856300833850949138862969136702392255589;
    
    uint256 constant IC8x = 15801347422695019615862358902882329719642754081599299050566268411173094024987;
    uint256 constant IC8y = 13750940741351851691687668155959530022539157350040602154561727214698216252041;
    
    uint256 constant IC9x = 14704755905919845217273664237351950037411807254484471982114126590743767120844;
    uint256 constant IC9y = 10869310130524632357989984509972362325427042789750589505043590277387527560644;
    
    uint256 constant IC10x = 9321536240187954005609566195397866488164414026743629621386232030406954625125;
    uint256 constant IC10y = 6701641947128021725716943034854377449331012302151187347500184419625166161850;
    
    uint256 constant IC11x = 8937940747425219565074145900777679999175526426481661889990029214095068783521;
    uint256 constant IC11y = 2085979486554755839332581910692088231072216022052101643275018603957380641059;
    
    uint256 constant IC12x = 11588481065851623113681279458266469482754728476287599989934048037652952796614;
    uint256 constant IC12y = 7103064377330058432313367288135128490856113730331696200753018818439907919590;
    
    uint256 constant IC13x = 15640784530157909406991194332646396290591646990113462868472072686247349531483;
    uint256 constant IC13y = 8351781129251860207374634573198981824033429104765942610057435022515723923050;
    
    uint256 constant IC14x = 10950219140723167525085714364489848695681692932358935916768914183944073847047;
    uint256 constant IC14y = 10545907470035529382478119734583241142226578630518730368098058887777671424377;
    
    uint256 constant IC15x = 13987973540372822057883994105970634344201984404484302274319538228196771538249;
    uint256 constant IC15y = 14356102968492968107807535611894160853970776241902635659524953891102931422631;
    
    uint256 constant IC16x = 16612002380852986087561903787497671899451161929534794475469957661329512003722;
    uint256 constant IC16y = 15352594810373497499166307241386265906739774700729289401219387564693466202739;
    
    uint256 constant IC17x = 6519483761011456104792664610381057307623366534641276381265729468561097909526;
    uint256 constant IC17y = 9518301350780964109625581121993370292157271249099639688808482681503589188957;
    
    uint256 constant IC18x = 7976902509522461414389126978537678603722724745792481624744469373452340385696;
    uint256 constant IC18y = 6476811126881741418468888370911763831299837332641446797374415802901259652121;
    
    uint256 constant IC19x = 9951375427432974822385321879956439014644888370119148242842190966779299923833;
    uint256 constant IC19y = 13550562766168527243567653085916986271445643383389700885955642898111137525368;
    
    uint256 constant IC20x = 5628331505211376431641079408206722184302292207177876900634206804297088475559;
    uint256 constant IC20y = 14386557404639860133240201275900555884074187474485821336779070240833601129722;
    
    uint256 constant IC21x = 14814105378095059213333112279799895491154786140114866305365937695252608456806;
    uint256 constant IC21y = 19138641696108044427208948872374956029187436739931776344948537143906677261122;
    
    uint256 constant IC22x = 3407162401426642963426610486677180009504084922471022282927685499588506105300;
    uint256 constant IC22y = 13597182258073273790320443086023635668533838388067293994058246217389778219311;
    
    uint256 constant IC23x = 11603032640521660052144892558266603654755687777852115070049443581249861014281;
    uint256 constant IC23y = 134865931810004383292514708589696801763213984784634417804560193134379212475;
    
    uint256 constant IC24x = 9528087041739186868671568426981127276540313510799381778438719343898030276869;
    uint256 constant IC24y = 14350142031522990492114009465844557486473002112801151888824339941487724953083;
    
    uint256 constant IC25x = 2058130386160636503678430870817421262570013202636568768927872999866772842969;
    uint256 constant IC25y = 8781615151734667509873402596219006938064882901532004077364463168178647107877;
    
    uint256 constant IC26x = 6592845750502733735488475430447768086789867862306739276378230348191583162947;
    uint256 constant IC26y = 20009349331866337593531559507801587750789634411393878514428240249844427919587;
    
    uint256 constant IC27x = 5595151464064382912495498584276079523399046833043989628843295343644202494554;
    uint256 constant IC27y = 15508134738094706416210592320869075193989430282847455434212726367154827164938;
    
    uint256 constant IC28x = 5794584557822898802765847496207610770172221019073503790012515147354754616196;
    uint256 constant IC28y = 5594518894183884129632030394740720637840300011957793500057805761684169091584;
    
    uint256 constant IC29x = 21137175636699398015583165910428662565843968068991896548623077002977523753179;
    uint256 constant IC29y = 8444760821544809668475918510841278733181646535987582182273073548497513106469;
    
    uint256 constant IC30x = 865646702052425178817079228467669494116890894856399111837998965705925727251;
    uint256 constant IC30y = 3937913363517898262544212616874970851384814344598276774501965504208772051555;
    
    uint256 constant IC31x = 21093688142267994861799468807714749982875340678307914769089998382867076818511;
    uint256 constant IC31y = 6305334867398724025894309270329885628807150592707951115552568154185281898748;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[31] calldata _pubSignals) public view returns (bool) {
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
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
