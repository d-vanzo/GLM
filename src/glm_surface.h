/******************************************************************************
 *                                                                            *
 * glm_surface.h                                                              *
 *                                                                            *
 * Developed by :                                                             *
 *     AquaticEcoDynamics (AED) Group                                         *
 *     School of Agriculture and Environment                                  *
 *     The University of Western Australia                                    *
 *                                                                            *
 *     http://aquatic.science.uwa.edu.au/                                     *
 *                                                                            *
 * Copyright 2013 - 2018 -  The University of Western Australia               *
 *                                                                            *
 *  This file is part of GLM (General Lake Model)                             *
 *                                                                            *
 *  GLM is free software: you can redistribute it and/or modify               *
 *  it under the terms of the GNU General Public License as published by      *
 *  the Free Software Foundation, either version 3 of the License, or         *
 *  (at your option) any later version.                                       *
 *                                                                            *
 *  GLM is distributed in the hope that it will be useful,                    *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 *  GNU General Public License for more details.                              *
 *                                                                            *
 *  You should have received a copy of the GNU General Public License         *
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                            *
 ******************************************************************************/
#ifndef _GLM_SURFACE_H_
#define _GLM_SURFACE_H_

void do_surface_thermodynamics(int jday, int iclock, int lwInd,
                                  AED_REAL Latitude, AED_REAL SWOld, AED_REAL SWNew);

//void recalc_surface_salt(void);

// void  still_air_correction(AED_REAL *Q_latentheat,
//                           AED_REAL *Q_sensible,
//                           AED_REAL  WindSp,
//                           AED_REAL  WaterTemp,
//                           AED_REAL  AirTemp,
//                           AED_REAL  p_atm,
//                           AED_REAL  humidity_surface,
//                           AED_REAL  humidity_altitude);

void  calc_latent_sensible_flux(AED_REAL *Q_latent,
                          AED_REAL *Q_sensible,
                          AED_REAL  WindSp,
                          AED_REAL  WaterTemp,
                          AED_REAL  AirTemp,
                          AED_REAL  p_atm,
                          AED_REAL  Vap_wat,
                          AED_REAL  Vap_atm);


AED_REAL atm_density(AED_REAL atmosPressure, AED_REAL vapPressure, AED_REAL AirTemp);

// AED_REAL  atmos_stability(AED_REAL *Q_latentheat,
//                           AED_REAL *Q_sensible,
//                           AED_REAL  WindSp,
//                           AED_REAL  WaterTemp,
//                           AED_REAL  AirTemp,
//                           AED_REAL  p_atm,
//                           AED_REAL  humidity_surface,
//                           AED_REAL  humidity_altitude);

//AED_REAL calculate_qsw(int kDays, int mDays, int iclock,
//                        AED_REAL Latitude, AED_REAL SWOld, AED_REAL ShortWave, AED_REAL WindSp);


#endif
