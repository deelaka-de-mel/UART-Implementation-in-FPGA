# UART Implementation in FPGA

A complete UART transceiver implemented in Verilog HDL and deployed on an FPGA (Cyclone IV E), developed as part of the EN2111 - Electronic Circuit Design module at the University of Moratuwa.

## Overview

This project implements a full UART communication system from scratch using discrete state machine logic in Verilog, with no IP cores. The design operates at **9600 baud** using a 50 MHz onboard clock, with the baud rate controlled via a `CLKS_PER_BIT = 5208` clock divider parameter.

## Architecture

The design consists of three Verilog modules:

- **Transmitter (`tx`)** — A 4-state FSM (IDLE → START → DATA → STOP) that serializes an 8-bit parallel input and drives it out over a single TX line, asserting `o_tx_done` on completion.
- **Receiver (`rx`)** — A mirrored 4-state FSM that detects the falling-edge start bit, samples each incoming bit at mid-period for noise immunity, reconstructs the 8-bit byte, and asserts `o_rx_done`.
- **Top-level (`uart_top`)** — Integrates TX and RX, generates a 1-second tick using a 26-bit counter at 50 MHz, auto-increments a transmit byte every second, and drives received data to onboard LEDs and two 7-segment displays (showing upper and lower nibbles in hex).

## Verification

A ModelSim testbench directly loopbacks the TX output to the RX input, transmits `0xA5`, and validates the received byte — printing `PASS` or `FAIL` to the console. Simulation waveforms confirm correct FSM transitions and bit timing.

## Hardware

Implemented and tested on the **Cyclone IV E** FPGA development board, with pin assignments for GPIO UART lines, slide switches, LEDs, and dual 7-segment displays confirmed via Quartus Pin Planner.
