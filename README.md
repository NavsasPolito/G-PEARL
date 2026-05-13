# G-PEARL

**GNSS Performance analysis, Experimental Assessment and Reporting tooL**

Developed by **Dr. Simone Zocca** and **Dr. Alex Minetto**  
Navigation signal analysis and Simulation (NavSAS) Research Group  
Department of Electronics and Telecommunications  
Politecnico di Torino

---

# Overview

G-PEARL (GNSS Performance analysis, Experimental Assessment and Reporting tooL) is a MATLAB-based standalone application designed to support technical and scientific investigations of GNSS data.

The software supports multiple GNSS data formats and enables the processing of:

- Raw IQ signal samples
- GNSS observables
- Receiver PVT solutions

G-PEARL provides automated report generation and advanced analysis functionalities for:

- Multi-frequency GNSS analysis
- Multi-constellation GNSS analysis
- Signal acquisition
- Signal strength characterization
- Visibility and availability analysis
- Multipath assessment
- Ionospheric analysis
- Doppler analysis
- Pseudorange analysis
- State estimation

The application has been designed to support technical and scientific investigations on GNSS datasets.

---

# Main Features

## Supported GNSS Constellations

G-PEARL currently supports:

- GPS
- GLONASS
- Galileo
- BeiDou

---

## Supported Input Formats

| Data Type | Supported Format |
|---|---|
| GNSS Observables | RINEX v3.04 |
| Receiver Positioning Logs | NMEA |
| IQ Samples | Binary `.bin` |

---

## Main Functionalities

- Multi-frequency signal analysis
- Multi-constellation support
- Automated experiment organization
- Automated result storage
- Interactive MATLAB plots
- Custom data tips
- Automatic report generation
- IQ acquisition processing
- STEC estimation
- Multipath detection
- DOP analysis
- PVT analysis

---

# License and Credits

G-PEARL is released under the **GNU General Public License v3.0 (GPLv3)**.

Please refer to the `licenses/` folder for the complete license text.

Development and testing activities were performed under the supervision of:

- Prof. Fabio Dovis

The application also includes packaged closed software authored by:

- Dr. Andrea Nardin
- Dr. Oliviero Vouch

---

# Installation Guide

## Prerequisites

Running `G_PEARL.exe` requires:

- MATLAB Runtime **R2023b (23.2)**
- Microsoft Word (optional, only required for automatic report generation)

> ⚠ Administrator privileges are required to install MATLAB Runtime.

---

# MATLAB Runtime Installation

## Option A — Download from MathWorks

The MATLAB Runtime R2023b installer can be downloaded from the official MathWorks website:

https://www.mathworks.com/products/compiler/mcr/index.html

For additional information regarding deployment:

- MATLAB Compiler Documentation
- Distribute Applications
- About Application Deployment
- Deployment Product Terms

---

## Option B — Automatic Installation

Inside the G-PEARL package, locate:

```text
for_redistribution/
```

Run:

```bash
MyAppInstaller_web.exe
```

with administrator privileges.

The installation wizard automatically installs:

- MATLAB Runtime
- G-PEARL application

---

# Installation Procedure

1. Install MATLAB Runtime R2023b using Option A or B.
2. Locate `G_PEARL.exe`.
3. Move the executable to the desired working directory if necessary.
4. Run the executable as administrator.

> On first execution, the MATLAB Runtime initialization may require several minutes.

---

# Application Startup

## Configuration Tab

From the **Configuration** tab, users can:

- Select RINEX observation files
- Select NMEA log files
- Specify a user name or session ID
- Choose output directories

After pressing:

```text
Load Data
```

all files are parsed into internal MATLAB structures and become available for processing.

---

# Session and Output Management

At the moment of parsing RINEX observation and NMEA log files:

- The current date and time are stored.
- A dedicated session folder is automatically created.

The output structure is organized as:

```text
USER_OUTPUT_PATH/
└── CURRENT_DATE/
    └── EXPERIMENT_ID/
        └── r01/
```

Example:

```text
USER_OUTPUT_PATH\CURRENT_DATE\1.a\r01
```

Each experiment maintains an independent run counter.

---

# RINEX Observation Files

The current version of G-PEARL is compatible with:

- RINEX version 3.04

This is the latest version supported by MATLAB function:

```matlab
rinexread.m
```

The notation of signal bands and channels follows the RINEX 3.04 standard.

---

# NMEA Support

G-PEARL supports NMEA log files for plotting and analyzing receiver PVT solutions.

The parsing is based on MATLAB function:

```matlab
nmeaParser.m
```

Parsed messages:

| Message | Usage |
|---|---|
| GGA | Receiver PVT information |
| RMC | Date extraction |

---

# Analysis Overview

Experiments are grouped into two categories:

| Category | Identifier |
|---|---|
| Observables Analysis | 1.x |
| Receiver State Estimation | 2.x |

Experiments can be executed independently and in any order.

---

# Interactive Plot Features

Some plots generated by G-PEARL include additional interactive features.

To enable all functionalities, include the following folder inside the MATLAB path:

```text
./library/common
```

---

# Interactive Legend

The interactive legend supports the following operations:

| Action | Function |
|---|---|
| Left Click | Toggle visibility of selected item |
| Shift + Left Click | Invert visibility of all items |
| Double Left Click | Show only L1/G1/E1/B1 measurements |

> Note: MATLAB legends are limited to 50 entries.

---

# Custom Data Tips

Clicking a point on a time series displays a custom data tip containing:

- Time
- Value
- Signal ID

The data tips are generated dynamically and therefore require the associated MATLAB functions to be available in the MATLAB path.

---

# 1. Observables Analysis

## 1.a Measure Signal Strength (C/N₀)

This experiment generates:

- Time series plots of all measured C/N₀ values.

---

## 1.b Evaluate Signal Visibility and PVT Availability

### Definitions

**Visibility**

Presence of measurements from a given satellite at a given time.

**Availability**

Capability to perform single-point positioning assuming inter-system offsets are known.

### User Parameters

- Adjustable C/N₀ threshold

Only satellites exceeding the threshold are considered.

### Generated Outputs

1. Number of unique visible satellites per frequency band
2. Number of unique visible satellites per constellation
3. PVT availability plots

If NMEA data is loaded and aligned in time, G-PEARL also evaluates receiver solution availability.

---

## 1.c Measure Raw Code Pseudoranges

This experiment generates:

- Time series of raw code pseudoranges not corrected by the receiver clock.

---

## 1.d Evaluate Pseudorange Errors

The experiment computes the finite-difference third derivative of:

- Code pseudoranges
- Phase pseudoranges

Purpose:

- Remove trends caused by satellite and receiver motion
- Obtain approximately zero-mean time series
- Preserve original variance

---

## 1.e Measure Doppler Shifts

This experiment generates:

- Time series plots of measured Doppler shifts.

---

## 1.f Evaluate Multipath Presence and Characteristics

The experiment computes the detrended dual-frequency Code-Minus-Carrier (2F CMC) observable.

Frequency pairs used:

| Constellation | Frequency Pair |
|---|---|
| GPS | L1 / L5 |
| GLONASS | G1 / G3 |
| Galileo | E1 / E5 |
| BeiDou | B1 / B3 |

### Optional Outlier Detection

Users can enable outlier detection based on:

- Rolling-window standard deviation
- User-defined threshold multiplier

Generated outputs include:

- 2F CMC time series
- Outlier tables
- PRN identifiers
- Epoch information
- Outlier values

---

## 1.g Evaluate Ionospheric Effects

### Outputs

#### Single-Frequency Code-Minus-Carrier (1F CMC)

The experiment generates:

- Single-frequency CMC time series
- Piece-wise zero-mean adjusted signals

Variations in 1F CMC are proportional to ionospheric delay variations.

#### STEC Estimation

The experiment estimates:

- Slant Total Electron Content (STEC)

Dual-frequency observations are used whenever available.

If multiple bands are available, the two furthest frequency bands are selected to improve estimation accuracy.

---

## 1.h Evaluate Presence of Interferences

Reserved for interference analysis functionalities.

---

# 2. Receiver State Estimation

Receiver state estimation is based on NMEA log files.

Minimum required message:

- GGA

Optional:

- RMC messages for date extraction

---

## 2.a Characterize Positioning Solutions

Generated outputs:

- Geographical trajectory plot
- Time series of estimated coordinates

Supported coordinate systems:

- Latitude / Longitude / Altitude (LLA)
- Earth-Centered Earth-Fixed (ECEF)

---

## 2.b Evaluate Dilution of Precision (DOP)

This experiment plots:

- HDOP values from GGA messages
- Number of satellites used

Other DOP metrics are not currently aligned due to missing timestamps in standard NMEA messages.

---

# IQ Samples Processing

Supported format:

```text
.bin
```

The current implementation supports acquisition on:

- GPS L1
- Galileo E1

---

# Acquisition Parameters

Users can independently configure acquisition settings for each band.

| Parameter | Description |
|---|---|
| Doppler Step Size | Doppler search resolution |
| Center Frequency | Doppler center frequency |
| Doppler Range | Total search bandwidth |
| Non-Coherent Accumulations | Number of accumulations |
| Coherent Integration Time | Integration duration |
| False Alarm Probability | Detection threshold |
| Doppler on Local Code | Enable Doppler correction on local code |

Default Doppler range:

```text
±5 kHz
```

(Default total search range = 10 kHz)

---

# IQ Analysis Outputs

Generated products include:

- Acquisition histograms
- Estimated C/N₀ values
- Estimated Doppler shifts
- Acquisition summary tables

PRNs considered acquired are highlighted in the histogram.

---

# Repository Structure

```text
G-PEARL/
├── docs/
├── licenses/
├── library/
│   └── common/
├── for_redistribution/
├── examples/
├── output/
└── README.md
```

---

# Citation

If you use G-PEARL in scientific work, please cite the related publications and acknowledge the NavSAS research group.

---

# Contact

Navigation signal analysis and Simulation (NavSAS) Research Group  
Department of Electronics and Telecommunications  
Politecnico di Torino

Email:

```text
name.surname@polito.it
```

