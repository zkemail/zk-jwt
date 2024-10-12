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
    uint256 constant r =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax =
        20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay =
        9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1 =
        4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2 =
        6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1 =
        21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2 =
        10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 =
        11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 =
        10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 =
        4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 =
        8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 =
        4619994144620127716802247722872087379434705525782886626109460213080162605530;
    uint256 constant deltax2 =
        6719634008987312941152437910359845763708558968285176660689775059319441182412;
    uint256 constant deltay1 =
        13492086188718327674650342825034459983892975807024410180581122632280388134744;
    uint256 constant deltay2 =
        13997690569586132098837312920720484431637115968800586952680908187039746879662;

    uint256 constant IC0x =
        19640474422181334534957078773977693356377639059557960550295038482753319896564;
    uint256 constant IC0y =
        9137164368229624603637857353795943189660617708261765996657385360219591750039;

    uint256 constant IC1x =
        14403077137445661557028067737744710008084271090477410833695232054096712565701;
    uint256 constant IC1y =
        12869407289214093925734277396024786510217883404322412518194286377685244770909;

    uint256 constant IC2x =
        9879680274091027372466017947053745710435935532227279515656379751780793957322;
    uint256 constant IC2y =
        12813401606746402029750601808410245265256080417058054851852447717540605136216;

    uint256 constant IC3x =
        2338923709860865516007492740327985296109741437959107811778474959306823516951;
    uint256 constant IC3y =
        7693330218466099181447207386294508718128013759720066487351433837428530837984;

    uint256 constant IC4x =
        6954090232258625455027223803345108921306462775452320027405601779629815067933;
    uint256 constant IC4y =
        21250780787802533153740177301256303863692876959023422001557566507903905602279;

    uint256 constant IC5x =
        18373619193922146577819656566431885880955964756504704488712745895468673021123;
    uint256 constant IC5y =
        3280107867526096127414517120056242204063356934790168010249968574766175279811;

    uint256 constant IC6x =
        11912310453867971284067974076658546820379074541739646168193234531829801930716;
    uint256 constant IC6y =
        16110803319859382336964018381529066998267902368003758554516670021975417327237;

    uint256 constant IC7x =
        19799878532939972909332465499061178025918369808633556162501179951080966411059;
    uint256 constant IC7y =
        8170220287885169718082771738595602416347730703213001742307960458725161644412;

    uint256 constant IC8x =
        16414406142700884034489993226687060086475075184421652211162059564452103143028;
    uint256 constant IC8y =
        18422811946686821473260635357218602775546245234237757781902965618931618782821;

    uint256 constant IC9x =
        21038668048663028954707524228321955687385051041496800549392370869549521461576;
    uint256 constant IC9y =
        20423001710567709762582495867683754098171721283974717149794378858275421856298;

    uint256 constant IC10x =
        9430610084957652115192043689225715637366002941331591244558736313937907596199;
    uint256 constant IC10y =
        4937593352567353017468381098577209691426215020091802934574626979881329955361;

    uint256 constant IC11x =
        14771003143713747512870775506913963178001905656137519287226272173061585339512;
    uint256 constant IC11y =
        20997697633567328521933118159715347588645669415366596015921386331972742809792;

    uint256 constant IC12x =
        4912006976303617370014961554249562403134055371066675600190151519452951962264;
    uint256 constant IC12y =
        8693126154358774255497495493308200011200971431574270567900198633054477745375;

    uint256 constant IC13x =
        19631433363319690319816202905483150955133793498898873496273663290403806295750;
    uint256 constant IC13y =
        3531296078538510944312262428010112242029954147127325704981517054174113068577;

    uint256 constant IC14x =
        16184036524290119954011643564998667019185313109709432669679338535972750056223;
    uint256 constant IC14y =
        1468189150845045413546444875729105084482021681072592662177881347865556894161;

    uint256 constant IC15x =
        2292637027854460939466841781668705050185430231878711632575136604483259426668;
    uint256 constant IC15y =
        8727775323888370966454500370301231121566000941352832376111995801558812860745;

    uint256 constant IC16x =
        17784239658890823523699006022650221155165417415514426477191582782771478447142;
    uint256 constant IC16y =
        21290238614680133259002194413609350088976681107909634439018110272253572293419;

    uint256 constant IC17x =
        12175928727301645475132505609735246822791385079494620818052270492054024058428;
    uint256 constant IC17y =
        17806986901723806184779673827208575764222836108683679129473054455754790268212;

    uint256 constant IC18x =
        1939422372621035584653914384099691100563934860989066550396449640923546593681;
    uint256 constant IC18y =
        19507674511153423789794263351472271240158532172643764524384339976985035133485;

    uint256 constant IC19x =
        16588760098933051928925096926157582439132954475576904949385236671829530538975;
    uint256 constant IC19y =
        5750602987335982274661787116214858134898247651999208619055909476362004106425;

    uint256 constant IC20x =
        18309144423310601906386171317796738421936670815029222946429933386306872703966;
    uint256 constant IC20y =
        20714639220477870528498726021293997459912135945172529046301493302105639439659;

    uint256 constant IC21x =
        17075219522299673511893553385955818982267387952814011233667062647121652360051;
    uint256 constant IC21y =
        14258508410831385211482400349603135774302769935526552671470909958261032525701;

    uint256 constant IC22x =
        14737714591654245429329649821215856819227408085993511732636916143254023516526;
    uint256 constant IC22y =
        12445060661135470283394418086209277672547324016859986153647415873340029887134;

    uint256 constant IC23x =
        20959300094016433449915020233569970752012481958056035150948631419924794301988;
    uint256 constant IC23y =
        6108220792558333349401933627235893934201170260330431307385598895199176061769;

    uint256 constant IC24x =
        6165279378941647128890756989003434330265626880763248136577549863738377019316;
    uint256 constant IC24y =
        20614281961170432747876629187250950672191677594997656598472478004453843214867;

    uint256 constant IC25x =
        2150642889892632442366697577208132951991020634811008912142879455439915659456;
    uint256 constant IC25y =
        121657449722509390466669517422014100463139165489804850342085897468579220311;

    uint256 constant IC26x =
        13957614859428334018106307904861673317655416229101527331339194406081032047267;
    uint256 constant IC26y =
        8608429084928526943048905213183383125863929669485728417372671419523459487674;

    uint256 constant IC27x =
        4654211522673062607498829489369821817111807999944801316911623723679059772102;
    uint256 constant IC27y =
        4992044683088444586964251109266634371943400811234119411118723605466297218861;

    uint256 constant IC28x =
        5298706124007119143892788262525059982943740421162447994039673665583345152408;
    uint256 constant IC28y =
        17076808170623141115498753859832879985943004376621087323573207506153990763198;

    uint256 constant IC29x =
        10245140667596167814132284369432091151873946760231343896075267370436442864054;
    uint256 constant IC29y =
        5458907828290924628463922546889590061524032235061798197280973392351963514712;

    uint256 constant IC30x =
        3965334873327918744196475535984354286956297143494364937172531582209729061874;
    uint256 constant IC30y =
        12074679941685254907747923540528855542419980032964161518645714492587370079121;

    uint256 constant IC31x =
        5225638451167567456369632628510955266003402142465505018692621390846535680130;
    uint256 constant IC31y =
        6252156256390978881961815016323358532747989391936912952955121280586231850736;

    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[31] calldata _pubSignals
    ) public view returns (bool) {
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

                g1_mulAccC(
                    _pVk,
                    IC10x,
                    IC10y,
                    calldataload(add(pubSignals, 288))
                )

                g1_mulAccC(
                    _pVk,
                    IC11x,
                    IC11y,
                    calldataload(add(pubSignals, 320))
                )

                g1_mulAccC(
                    _pVk,
                    IC12x,
                    IC12y,
                    calldataload(add(pubSignals, 352))
                )

                g1_mulAccC(
                    _pVk,
                    IC13x,
                    IC13y,
                    calldataload(add(pubSignals, 384))
                )

                g1_mulAccC(
                    _pVk,
                    IC14x,
                    IC14y,
                    calldataload(add(pubSignals, 416))
                )

                g1_mulAccC(
                    _pVk,
                    IC15x,
                    IC15y,
                    calldataload(add(pubSignals, 448))
                )

                g1_mulAccC(
                    _pVk,
                    IC16x,
                    IC16y,
                    calldataload(add(pubSignals, 480))
                )

                g1_mulAccC(
                    _pVk,
                    IC17x,
                    IC17y,
                    calldataload(add(pubSignals, 512))
                )

                g1_mulAccC(
                    _pVk,
                    IC18x,
                    IC18y,
                    calldataload(add(pubSignals, 544))
                )

                g1_mulAccC(
                    _pVk,
                    IC19x,
                    IC19y,
                    calldataload(add(pubSignals, 576))
                )

                g1_mulAccC(
                    _pVk,
                    IC20x,
                    IC20y,
                    calldataload(add(pubSignals, 608))
                )

                g1_mulAccC(
                    _pVk,
                    IC21x,
                    IC21y,
                    calldataload(add(pubSignals, 640))
                )

                g1_mulAccC(
                    _pVk,
                    IC22x,
                    IC22y,
                    calldataload(add(pubSignals, 672))
                )

                g1_mulAccC(
                    _pVk,
                    IC23x,
                    IC23y,
                    calldataload(add(pubSignals, 704))
                )

                g1_mulAccC(
                    _pVk,
                    IC24x,
                    IC24y,
                    calldataload(add(pubSignals, 736))
                )

                g1_mulAccC(
                    _pVk,
                    IC25x,
                    IC25y,
                    calldataload(add(pubSignals, 768))
                )

                g1_mulAccC(
                    _pVk,
                    IC26x,
                    IC26y,
                    calldataload(add(pubSignals, 800))
                )

                g1_mulAccC(
                    _pVk,
                    IC27x,
                    IC27y,
                    calldataload(add(pubSignals, 832))
                )

                g1_mulAccC(
                    _pVk,
                    IC28x,
                    IC28y,
                    calldataload(add(pubSignals, 864))
                )

                g1_mulAccC(
                    _pVk,
                    IC29x,
                    IC29y,
                    calldataload(add(pubSignals, 896))
                )

                g1_mulAccC(
                    _pVk,
                    IC30x,
                    IC30y,
                    calldataload(add(pubSignals, 928))
                )

                g1_mulAccC(
                    _pVk,
                    IC31x,
                    IC31y,
                    calldataload(add(pubSignals, 960))
                )

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(
                    add(_pPairing, 32),
                    mod(sub(q, calldataload(add(pA, 32))), q)
                )

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

                let success := staticcall(
                    sub(gas(), 2000),
                    8,
                    _pPairing,
                    768,
                    _pPairing,
                    0x20
                )

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
