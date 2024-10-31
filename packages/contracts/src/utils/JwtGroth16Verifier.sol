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
        5292283836550160867723844084185126361620768855998666908315341166711776234622;
    uint256 constant deltax2 =
        1342959570752483303064790375992692346001971508730169109952364131021995024582;
    uint256 constant deltay1 =
        17467633401301246916352105065965749375632636258450261448662165678914818762636;
    uint256 constant deltay2 =
        15823289535448387447284156201346511216550926614778764722179465152395978744810;

    uint256 constant IC0x =
        21751371255095685317014895786677047388192106570978108165286451534489404061115;
    uint256 constant IC0y =
        13580022637228786725781554676337171303041778749619942299027209302472222816088;

    uint256 constant IC1x =
        3307274085462115651214473937881900652676640436526837726111987515764577283051;
    uint256 constant IC1y =
        6637085473544843346200656836215262582035733970703601931469631074954047680369;

    uint256 constant IC2x =
        5171084984408115651848539685543660101653077104215802042654516774135455619858;
    uint256 constant IC2y =
        20336375515586656057047998310410146571700021115723194671356991544420449916424;

    uint256 constant IC3x =
        11836232866662364494552698318220771261306179947213691908306079111711305849297;
    uint256 constant IC3y =
        9389532870131004743607733046029854228720231612317761835719599415882419435877;

    uint256 constant IC4x =
        8669364981821557193203948727301680152858945576319015074741882528499477549389;
    uint256 constant IC4y =
        11777087557878751259950341297552582449753154884833872155752773985522222024693;

    uint256 constant IC5x =
        1054186781107875588619977007414781351455403737972070803138701902200307636986;
    uint256 constant IC5y =
        10758997101380449685077855694113368081093014570832689385614803211492988624153;

    uint256 constant IC6x =
        19963869551276908536557368378863959316845839744346673858294886958400288632396;
    uint256 constant IC6y =
        13256401127849763697280902959013676941710572817101292362426369698264283702912;

    uint256 constant IC7x =
        9887738220935657515490180900018029791307726604976903756684231518126136768038;
    uint256 constant IC7y =
        11048324757006822176252496419769382036281857397046177801488236127873681092500;

    uint256 constant IC8x =
        6542466874576082653041855683100845552028475352922999580954929861811410887287;
    uint256 constant IC8y =
        16375768583323665396743069857557007970591986397599518491734061737377067682697;

    uint256 constant IC9x =
        952681932744331063128305937763581437297625392531383893850977861808907532949;
    uint256 constant IC9y =
        21084513803953991240915170399385873238250719470615280040934115068138152284238;

    uint256 constant IC10x =
        3605659605477918450465296090719470613782327287681335109974508660431862119461;
    uint256 constant IC10y =
        2940495872781511585114609441636316553078387711873671192466502960713560587412;

    uint256 constant IC11x =
        7964851370436564582210676357796764373791986981084577307186207085191640812445;
    uint256 constant IC11y =
        6969205004718801897204638798960163704939826198783808149432859178486777191850;

    uint256 constant IC12x =
        74607832277659385043922201805122153437222902595482177760088776556416767047;
    uint256 constant IC12y =
        6320958224393951815556007861235852773591120297917071702370163086966172252866;

    uint256 constant IC13x =
        2410015756107034730180225301557620314230106666143361206900583513934880624038;
    uint256 constant IC13y =
        11123279145101633567564905291078583020712343693767271599793770793666558497831;

    uint256 constant IC14x =
        15547632039432509152668915224849582355074484532775356067503852671160468484402;
    uint256 constant IC14y =
        2694863187746700878785099789433914001786700572005868410082447872148879850773;

    uint256 constant IC15x =
        3858194260864453298237336706645668932902916443071179407517190139218234243743;
    uint256 constant IC15y =
        11965610666945256424075227744558276151247766800663020464869081435352478873900;

    uint256 constant IC16x =
        10241674513646064071657899709283729916485419323363517080537336207250298901205;
    uint256 constant IC16y =
        16938641843704287682911068347645801146991946835528301793870170013756034266546;

    uint256 constant IC17x =
        15901867644364156848499706725013821528782051669312597469504838578005427408341;
    uint256 constant IC17y =
        14517994300486919117598719213442192300092009187868138693835558356004069420056;

    uint256 constant IC18x =
        6540565230255829235730928312995145773893446621112493867024599139952800303913;
    uint256 constant IC18y =
        11317582069216655464724136668181412823627633648390729692400492733794149269119;

    uint256 constant IC19x =
        21337293999204869022443167443255301940333517939590997102777343353943742223462;
    uint256 constant IC19y =
        4334799759502714646614079598291929841754374172632120214053956805876766279778;

    uint256 constant IC20x =
        6163373100455788975570809999922211323104154667521048539785962184791587106504;
    uint256 constant IC20y =
        1558357450920124716071169467579356674488281602470102899782687082471637833945;

    uint256 constant IC21x =
        19079099277684390821635669871238092273440642471348908626790858494386817145975;
    uint256 constant IC21y =
        801411784686683637657115581870842173560832477059548505180941385488151455172;

    uint256 constant IC22x =
        3623646002188785341771449618695062692267881943137384944483372052925960488541;
    uint256 constant IC22y =
        1067538663390965032904839676422186716706821856039872268821493761078184750676;

    uint256 constant IC23x =
        2650136849059345638890820896682539188814923653306557645096291476714245289844;
    uint256 constant IC23y =
        11699045798223598239921590553176166844800864968147239596175987430580391408947;

    uint256 constant IC24x =
        6443067562015370974579397514960815090756675090678047421058650703619129448787;
    uint256 constant IC24y =
        4617656949926381841629101554802852185833837218434646791475844898431328971998;

    uint256 constant IC25x =
        14737739188298180042167619745712390485890741186568183559290184900921570588426;
    uint256 constant IC25y =
        4637403637805930059445040992855511779991598238302204575016915504596225776424;

    uint256 constant IC26x =
        15965598828623695798946284984909568915843093225150824363875231595488107054433;
    uint256 constant IC26y =
        20156919845637380048200539470362702243372010191284108493354639454546658092788;

    uint256 constant IC27x =
        14760420679371250076438079962505901308682708684822637341685749088135626276073;
    uint256 constant IC27y =
        10966549041301317879325540196879390717178472349261730138489322192990490201561;

    uint256 constant IC28x =
        805861610605796859584340595182497755944744596903763787972606725235584118739;
    uint256 constant IC28y =
        17226444376066286248979506647292386475412725573850923043113936355593014427108;

    uint256 constant IC29x =
        4316475684912052795381023705853922819958761711465358541783457809428487363324;
    uint256 constant IC29y =
        2931081156320635732249682341904652274058135919224560922869641896515449564167;

    uint256 constant IC30x =
        2839363689417669986398049399503925941498042678152704681827973706968885410373;
    uint256 constant IC30y =
        9565781797909708238323043653709597961773830755983320835330937912246360404436;

    uint256 constant IC31x =
        20271208900395415667228295415155457008375399376168342833536069686631665918037;
    uint256 constant IC31y =
        16584964928852253328729825236991324420781522394409941346421655493896463491666;

    uint256 constant IC32x =
        1772606115543405197674069488635798979379211704101025428202620883744143627456;
    uint256 constant IC32y =
        21693632415685740232588912110229325107291451667148908643608686025756605240666;

    uint256 constant IC33x =
        2629390336337878859556275351049339649248252465051636278526365933759265452762;
    uint256 constant IC33y =
        5597620971636450119096661951857622472526602542746923880898942279686570357754;

    uint256 constant IC34x =
        18662706677624348229724814074932904599521542054601574944029199622430856658812;
    uint256 constant IC34y =
        20769745781618592068131320591503781336490790005537203956901593228590539950067;

    uint256 constant IC35x =
        10030303771233055203259439154228184211247497004026191837590706332018280941074;
    uint256 constant IC35y =
        14945399902889163277824326215354429919075005091818055564200749392080678445445;

    uint256 constant IC36x =
        5011588350592154101308714982532770918451839301567488422253745041131528052882;
    uint256 constant IC36y =
        6258475378696814228704855703484932660223662510284886382171650504425111597557;

    uint256 constant IC37x =
        21883122527577470032484267961665460475531044927178244993518012260040893279027;
    uint256 constant IC37y =
        1057677806587437687769745162966723769549720667554012535686673922694300543463;

    uint256 constant IC38x =
        17347665799405622121355438620008527051286939001010989699151167068007285825044;
    uint256 constant IC38y =
        13585930188817318763171550929389231984420837207563729230484006767019257918030;

    uint256 constant IC39x =
        16081597856155580261221606698436256670017614174713832712323693832371378309383;
    uint256 constant IC39y =
        3602263267814357712002420494919448480406828517138580487712284781122524601399;

    uint256 constant IC40x =
        5529967420278188037700457408020574597401556298006547264135671202407167987622;
    uint256 constant IC40y =
        8468210941197103246672214750115434920148186013380976426983750253567278474104;

    uint256 constant IC41x =
        7106446034747958904857225958404890236730953218383683312467001977047494307004;
    uint256 constant IC41y =
        15806931895910868717651831796872955556900979529187822360809117258769342885751;

    uint256 constant IC42x =
        13581067128362013147590954191665609011651703478855450869802955822410229986074;
    uint256 constant IC42y =
        11785019347712035674570336010091771501660028228272258865391646232893778134368;

    uint256 constant IC43x =
        13210442771849194321553592046102129735507813893308456202502586511568211417330;
    uint256 constant IC43y =
        9597659442756899145159045644143230173720039078984262504943104218701179982895;

    uint256 constant IC44x =
        13696436457923885632965701637815623020128203604508909297125084757872873229817;
    uint256 constant IC44y =
        5112648345105580492613689818257156326211703077402108921519947076284290706207;

    uint256 constant IC45x =
        7788843281090787765522488040992211779858336813303371786697597263579625474571;
    uint256 constant IC45y =
        10916486337786815372389737932367919908159534928894472988144608170402240415987;

    uint256 constant IC46x =
        18970977700569301220687752799101884979790166569420870758728984427819138881985;
    uint256 constant IC46y =
        16902906293326949080311382646937832561899220174346618604397486729703991028708;

    uint256 constant IC47x =
        20356318403288994399005428565646188660426079453993952920094531298577757961457;
    uint256 constant IC47y =
        9642081527300310667841424646171257279814107709927519544380151642157452930642;

    uint256 constant IC48x =
        19391468584288153832076422196280185872376977198878140653175861603515221033246;
    uint256 constant IC48y =
        11353525185659374178184880440254079825742450337987937409262083072380649063038;

    uint256 constant IC49x =
        19323427082190157282809565923841647760981181482488388109482157657974923379961;
    uint256 constant IC49y =
        5015476574386533390837490117752443436630413282813306313564273512218160566605;

    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[49] calldata _pubSignals
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

                g1_mulAccC(
                    _pVk,
                    IC32x,
                    IC32y,
                    calldataload(add(pubSignals, 992))
                )

                g1_mulAccC(
                    _pVk,
                    IC33x,
                    IC33y,
                    calldataload(add(pubSignals, 1024))
                )

                g1_mulAccC(
                    _pVk,
                    IC34x,
                    IC34y,
                    calldataload(add(pubSignals, 1056))
                )

                g1_mulAccC(
                    _pVk,
                    IC35x,
                    IC35y,
                    calldataload(add(pubSignals, 1088))
                )

                g1_mulAccC(
                    _pVk,
                    IC36x,
                    IC36y,
                    calldataload(add(pubSignals, 1120))
                )

                g1_mulAccC(
                    _pVk,
                    IC37x,
                    IC37y,
                    calldataload(add(pubSignals, 1152))
                )

                g1_mulAccC(
                    _pVk,
                    IC38x,
                    IC38y,
                    calldataload(add(pubSignals, 1184))
                )

                g1_mulAccC(
                    _pVk,
                    IC39x,
                    IC39y,
                    calldataload(add(pubSignals, 1216))
                )

                g1_mulAccC(
                    _pVk,
                    IC40x,
                    IC40y,
                    calldataload(add(pubSignals, 1248))
                )

                g1_mulAccC(
                    _pVk,
                    IC41x,
                    IC41y,
                    calldataload(add(pubSignals, 1280))
                )

                g1_mulAccC(
                    _pVk,
                    IC42x,
                    IC42y,
                    calldataload(add(pubSignals, 1312))
                )

                g1_mulAccC(
                    _pVk,
                    IC43x,
                    IC43y,
                    calldataload(add(pubSignals, 1344))
                )

                g1_mulAccC(
                    _pVk,
                    IC44x,
                    IC44y,
                    calldataload(add(pubSignals, 1376))
                )

                g1_mulAccC(
                    _pVk,
                    IC45x,
                    IC45y,
                    calldataload(add(pubSignals, 1408))
                )

                g1_mulAccC(
                    _pVk,
                    IC46x,
                    IC46y,
                    calldataload(add(pubSignals, 1440))
                )

                g1_mulAccC(
                    _pVk,
                    IC47x,
                    IC47y,
                    calldataload(add(pubSignals, 1472))
                )

                g1_mulAccC(
                    _pVk,
                    IC48x,
                    IC48y,
                    calldataload(add(pubSignals, 1504))
                )

                g1_mulAccC(
                    _pVk,
                    IC49x,
                    IC49y,
                    calldataload(add(pubSignals, 1536))
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

            checkField(calldataload(add(_pubSignals, 1024)))

            checkField(calldataload(add(_pubSignals, 1056)))

            checkField(calldataload(add(_pubSignals, 1088)))

            checkField(calldataload(add(_pubSignals, 1120)))

            checkField(calldataload(add(_pubSignals, 1152)))

            checkField(calldataload(add(_pubSignals, 1184)))

            checkField(calldataload(add(_pubSignals, 1216)))

            checkField(calldataload(add(_pubSignals, 1248)))

            checkField(calldataload(add(_pubSignals, 1280)))

            checkField(calldataload(add(_pubSignals, 1312)))

            checkField(calldataload(add(_pubSignals, 1344)))

            checkField(calldataload(add(_pubSignals, 1376)))

            checkField(calldataload(add(_pubSignals, 1408)))

            checkField(calldataload(add(_pubSignals, 1440)))

            checkField(calldataload(add(_pubSignals, 1472)))

            checkField(calldataload(add(_pubSignals, 1504)))

            checkField(calldataload(add(_pubSignals, 1536)))

            checkField(calldataload(add(_pubSignals, 1568)))

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
            return(0, 0x20)
        }
    }
}
