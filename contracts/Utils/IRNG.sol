// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;


interface IRNG {
  function d10 ( uint256 _input ) external returns ( uint256 );
  function d100 ( uint256 _input ) external returns ( uint256 );
  function d1000 ( uint256 _input ) external returns ( uint256 );
  function d12 ( uint256 _input ) external returns ( uint256 );
  function d20 ( uint256 _input ) external returns ( uint256 );
  function d4 ( uint256 _input ) external returns ( uint256 );
  function d6 ( uint256 _input ) external returns ( uint256 );
  function d8 ( uint256 _input ) external returns ( uint256 );
  function dn ( uint256 _input, uint256 _number ) external returns ( uint256 );
}
