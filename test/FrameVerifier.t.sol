// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FrameVerifier} from "../src/FrameVerifier.sol";
import "../src/Encoder.sol";

contract FrameVerifierTest is Test {
    function test_EncodeAndVerify() public {
        MessageData memory md = MessageData({
            type_: MessageType.MESSAGE_TYPE_FRAME_ACTION,
            fid: 64417,
            timestamp: 97190733,
            network: FarcasterNetwork.FARCASTER_NETWORK_TESTNET,
            frame_action_body: FrameActionBody({
                url: hex"68747470733a2f2f6578616d706c652e636f6d",
                button_index: 1,
                cast_id: CastId({fid: 64417, hash: hex"e9eca527e4d2043b1f77b5b4d847d4f71172116b"}),
                input_text: hex""
            })
        });
        assertEq(
            MessageDataCodec.encode(md),
            // result from hub monorepo
            hex"080d10a1f70318cd86ac2e20028201330a1368747470733a2f2f6578616d706c652e636f6d10011a1a08a1f7031214e9eca527e4d2043b1f77b5b4d847d4f71172116b"
        );

        // from hub mono repo
        bytes memory sigHex =
            hex"17bdafddf9cf7464959a28d57fb5da7c596de4796f663588ea24d804c13ca043f46a546ca474d1b4420cc48e8720d8051786b21a689cdf485f78e51e36a12b05";
        (bytes32 r, bytes32 s) = abi.decode(sigHex, (bytes32, bytes32));
        bytes32 pk = 0x292404752ddd67080bbfe93af4017e51388ebc3c9fb96b8984658155de590b38;
        bool ret = FrameVerifier.verifyMessageData({public_key: pk, signature_r: r, signature_s: s, messageData: md});
        assertTrue(ret);
    }

    function test_EncodeAndVerifyInput() public {
        MessageData memory md = MessageData({
            type_: MessageType.MESSAGE_TYPE_FRAME_ACTION,
            fid: 7963,
            timestamp: 98540719,
            network: FarcasterNetwork.FARCASTER_NETWORK_MAINNET,
            frame_action_body: FrameActionBody({
                url: bytes("https://frame-validator.vercel.app"),
                button_index: 1,
                cast_id: CastId({fid: 7963, hash: hex"96c49b075c011d344f08ae7cb6f90512a3aff958"}),
                input_text: bytes("horse")
            })
        });
        assertEq(
            MessageDataCodec.encode(md),
            // result from hub monorepo
            hex"080d109b3e18afb9fe2e20018201480a2268747470733a2f2f6672616d652d76616c696461746f722e76657263656c2e61707010011a19089b3e121496c49b075c011d344f08ae7cb6f90512a3aff9582205686f727365"
        );

        // from hub mono repo
        bytes memory sigHex =
            hex"92174ad4c865d9ecc30901c9a7b9fad0ed983a2f10eaad710585f731453a8187f0eac27978c8c91bc2038f1929e6fc2a1ecdaa459ea7572ad4273458bc742a04";
        (bytes32 r, bytes32 s) = abi.decode(sigHex, (bytes32, bytes32));
        bytes32 pk = 0x94fec6dd277668cf5db24b408b79f91aa987fb20e4778fdd2bc94375f7f361f1;
        bool ret = FrameVerifier.verifyMessageData({public_key: pk, signature_r: r, signature_s: s, messageData: md});
        assertTrue(ret);
    }
}
