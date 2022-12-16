//
//  PCRpredictionAPI.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/11.
//

import Foundation

class RungeKutta {
    func rk4(y: [Double], dydx: [Double], h: Double, f: ([Double]) -> [Double] ) -> [Double] {
        // given y[] and dydx[] at x, use 4th order Runge-Kutta to advance solution over an interval h
        // f returns derivatives at x, i.e. y'(x) = f(y, x)
        let n = y.count  // number of first order ODE
        let hh = 0.5 * h    // half interval
        var yt = [Double](repeating: 0.0, count: n) // temporary storage
        for i in 0..<n { yt[i] = y[i] + hh * dydx[i] }  // first step
        var dyt = f(yt)                             // get dydx at half time step
        for i in 0..<n { yt[i] = y[i] + hh * dyt[i] }   // second step
        var dym = f(yt)                             // get updated dydx at half time step
        for i in 0..<n {
            yt[i] = y[i] + h * dym[i]                   // third step
            dym[i] = dyt[i] + dym[i]
        }
        dyt = f(yt)                              // fourth step
        for i in 0..<n { yt[i] = y[i] + h * (dydx[i] + dyt[i] + 2.0 * dym[i]) / 6.0 }   // do final step w/ appropriate weights
        return yt   // return updated y[] at x+h
    }
}

// Sleep/wake Regulation Parameters
let v_vh = 1.0, Q_max = 100.0, Q_th = 1.0, theta = 10.0, sigma = 3.0, tau_m = 10.0/(60*60), tau_v = 10.0/(60*60), chi = 45.0, mu = 4.2, v_mv = 1.8, v_vm = 2.1, v_vc = 3.37, A_m = 1.3, A_v = -10.2

// Circadian Parameters
let tau_c = 24.09, coef_x = -0.47, alpha_0 = 0.16, beta = 0.013, p = 0.6, i_0 = 9500.0, lambda1 = 60.0, G = 19.9, b = 0.4, gamma = 0.23, kappa = 12.0/Double.pi, k = 0.55, f = 0.99669, coef_y = 0.8

// Vv and Vm values during forced / normal wake and sleep
let forced_wake_Vm = 1.1214,forced_sleep_Vm = -13.2
let forced_wake_Qm = Q_max / (1.0 + exp(-(forced_wake_Vm-theta)/sigma)), forced_sleep_Qm = Q_max / (1.0 + exp(-(forced_sleep_Vm-theta)/sigma))

let normal_wake_Vm = 0.9743, normal_sleep_Vm = -11.5246
let normal_wake_Qm = Q_max / (1.0 + exp(-(normal_wake_Vm-theta)/sigma)), normal_sleep_Qm = Q_max / (1.0 + exp(-(normal_sleep_Vm-theta)/sigma))

func PCR_normal_wake(V: [Double]) -> [Double] {
    var dVdt = [Double](repeating: 0.0, count: 4)
    dVdt[0] = (1 / kappa) * ( gamma * ( V[0] - (4 * pow(V[0],3)/3) ) - V[1] * ( pow((24 / (f * tau_c)),2) + k * G * alpha_0 * (1-V[2]) * (1-b*V[0]) * (1-b*V[1]) * pow((500)/i_0,p)))
    dVdt[1] = (1 / kappa) * ( V[0] + G * alpha_0 * (1-V[2]) * (1-b*V[0]) * (1-b*V[1]) * pow((500)/i_0,p))
    dVdt[2] = lambda1 * (alpha_0 * (pow((500)/i_0,p)) * (1-V[2]) - beta * V[2] )
    dVdt[3] = (1 / chi) * (-V[3] + mu * normal_wake_Qm)
    return dVdt
}

func PCR_normal_sleep(V: [Double]) -> [Double] {
    var dVdt = [Double](repeating: 0.0, count: 4)
    dVdt[0] = (1 / kappa) * ( gamma * ( V[0] - (4 * pow(V[0],3)/3) ) - V[1] * ( pow((24 / (f * tau_c)),2)))
    dVdt[1] = (1 / kappa) * ( V[0] )
    dVdt[2] = lambda1 * (-beta * V[2])
    dVdt[3] = (1 / chi) * (-V[3] + mu * normal_sleep_Qm )
    return dVdt
}

func PCR_forced_wake(V: [Double]) -> [Double] {
    var dVdt = [Double](repeating: 0.0, count: 4)
    dVdt[0] = (1 / kappa) * ( gamma * ( V[0] - (4 * pow(V[0],3)/3) ) - V[1] * ( pow((24 / (f * tau_c)),2) + k * G * alpha_0 * (1-V[2]) * (1-b*V[0]) * (1-b*V[1]) * pow((500)/i_0,p)))
    dVdt[1] = (1 / kappa) * ( V[0] + G * alpha_0 * (1-V[2]) * (1-b*V[0]) * (1-b*V[1]) * pow((500)/i_0,p))
    dVdt[2] = lambda1 * (alpha_0 * (pow((500)/i_0,p)) * (1-V[2]) - beta * V[2] )
    dVdt[3] = (1 / chi) * (-V[3] + mu * forced_wake_Qm)
    return dVdt
}

func PCR_forced_sleep(V: [Double]) -> [Double] {
    var dVdt = [Double](repeating: 0.0, count: 4)
    dVdt[0] = (1 / kappa) * ( gamma * ( V[0] - (4 * pow(V[0],3)/3) ) - V[1] * ( pow((24 / (f * tau_c)),2)))
    dVdt[1] = (1 / kappa) * ( V[0] )
    dVdt[2] = lambda1 * (-beta * V[2])
    dVdt[3] = (1 / chi) * (-V[3] + mu * forced_sleep_Qm)
    return dVdt
}

// Simulate PCR model according to sleep input
// V0: initial condition (1x6 list)
// sleep_pattern: 0-1 timeseries , [step]h record (1.0 = sleep, 0.0 = wake)
// step: period of the sleep pattern record

func pcr_simulation(V0: [Double], sleep_pattern: [Double], step: Double) -> [[Double]]{
    let duration = sleep_pattern.count
    var y = [[Double]]()
    var V_tmp = V0
    var H, C, D_up, D_down: Double
    let rk = RungeKutta()
    y.append(V0)
    for i in 0...(duration-2){ //simulate every 1 min range
        H = V_tmp[3]
        C = 3.37*0.5*(1+coef_y*V_tmp[1] + coef_x*V_tmp[0])
        D_up = (2.46+10.2+C) //sleep thres
        D_down = (1.45+10.2+C) //wake thres
        
        //if model simulation and sleep pattern do not match
        if (D_down > H) && (sleep_pattern[i+1] > 0.5){ //forced sleep case
            V_tmp = rk.rk4(y: V_tmp, dydx: PCR_forced_sleep(V: V_tmp), h: step, f: PCR_forced_sleep)
        }
        else if (D_up < H) && (sleep_pattern[i+1] < 0.5){ //forced wake case
            V_tmp = rk.rk4(y: V_tmp, dydx: PCR_forced_wake(V: V_tmp), h: step, f: PCR_forced_wake)
        }
        else if (D_down <= H) && (sleep_pattern[i+1] > 0.5){ //normal sleep case
            V_tmp = rk.rk4(y: V_tmp, dydx: PCR_normal_sleep(V: V_tmp), h: step, f: PCR_normal_sleep)
        }
        else{ //normal wake case
            V_tmp = rk.rk4(y: V_tmp, dydx: PCR_normal_wake(V: V_tmp), h: step, f: PCR_normal_wake)
        }
        y.append(V_tmp) //record the model simulation result
    }
    return y //return the simulation result
}

// Suggest CSS sleep pattern based on current state, sleep onset, and work schedule
// <input>
// V0: current state of the model [ x y n H ]
// ** current state is 0
// sleep onset: upcomming sleep onset (step)
// work_onset: work onset of the next day's schedule (step)
// work_offset: work onset of the next day's schedule (step)
// 0 < sleep_onset < work_onset < work_offset

// <output> np.array objective containing
// CSS: [CSS_sleep_onset, CSS_sleep_offset] (step)
// if CSS sleep is impossible, CSS_sleep = [0, 0];
// Nap: [Nap_onset Nap_offset], minute from current time
// if nap sleep is impossible, Nap = [0,0];
func Sleep_pattern_suggestion(V0: [Double], sleep_onset: Int, work_onset: Int, work_offset: Int, step: Double)->(CSS: [Int], Nap: [Int]){
    let unit = Int(0.5/step) // Time between nap offset and work onset
    var len0 = work_onset - sleep_onset - unit // length between work onset and work onset
    var len1 = work_offset - work_onset
    var i: Int // iterator
    let rk = RungeKutta() // R-K class
    var CSS = [0, 0] //Output 1
    var Nap = [0, 0] //Output 2

    if sleep_onset <= 0 || len0 <= 0 || len1 <= 0 { // Wrong input
        return (CSS, Nap)
    }

    // Find CSS sleep
    var sleep_pattern = [Double](repeating: 0.0, count: sleep_onset+1)
    let y = pcr_simulation(V0: V0, sleep_pattern: sleep_pattern, step: step) // simulate from current to sleep onset
    var V_tmp = y[sleep_onset]
    var H = V_tmp[3] // sleep pressure
    var C = (3.37*0.5)*(1.0+coef_y*V_tmp[1]+coef_x*V_tmp[0])
    var D_up = (2.46 + 10.2 + C)/v_vh // sleep threshold

    var sleep_start = 0 // first point where the CSS sleep is possible
    var sleep_amount = 0 // duration of the CSS sleep

    if D_up > H{ // CSS sleep is impossible at sleep onset -> Need more awake
        i = 0
        repeat{ // find the point where the CSS sleep is possible
            V_tmp = rk.rk4(y: V_tmp, dydx: PCR_normal_wake(V: V_tmp), h: step, f: PCR_normal_wake) // simulate awake
            H = V_tmp[3]
            C = (3.37*0.5)*(1.0 + coef_y*V_tmp[1] + coef_x*V_tmp[0])
            D_up = (2.46 + 10.2 + C)/v_vh
            i = i + 1
            if D_up < H {
                break
            }
        }while(i < len0)
        
        if i == len0 { //CSS sleep is impossible before the work onset
            V_tmp = y[sleep_onset];
        }
        else{
            sleep_start = i // the earliest time that CSS sleep is possible
            i = 0
            repeat{
                i = i + 1
                V_tmp = rk.rk4(y: V_tmp, dydx: PCR_normal_sleep(V: V_tmp), h: step, f: PCR_normal_sleep)
                H = V_tmp[3]
                C = (3.37*0.5)*(1.0 + coef_y*V_tmp[1] + coef_x*V_tmp[0])
                D_up = (2.46 + 10.2 + C)/v_vh
            } while(D_up < H)
            sleep_amount = i
        }
    }
    else { // CSS sleep is possible at the sleep onset
        sleep_start = 0
        i = 0
        repeat{
            i = i+1
            V_tmp = rk.rk4(y: V_tmp, dydx: PCR_normal_sleep(V: V_tmp), h: step, f: PCR_normal_sleep)
            H = V_tmp[3]
            C = (3.37*0.5)*(1.0 + coef_y*V_tmp[1] + coef_x*V_tmp[0])
            D_up = (2.46 + 10.2 + C)/v_vh
        } while (D_up <= H)
        sleep_amount = i
    }
    var CSS_start = 0
    var CSS_end = 0

    if sleep_start + sleep_amount >= len0{
        CSS = [sleep_onset, work_onset - unit]
        //return (CSS, Nap)
    }
    if sleep_amount < unit{ // CSS sleep is impossible or meaningless
        CSS = [0, 0];
        CSS_end = sleep_onset + sleep_start // start of CSS sleep
        V_tmp = y[sleep_onset]
    }
    else{ // CSS sleep is identified
        CSS_start = sleep_onset + sleep_start // start of CSS sleep
        CSS_end = CSS_start + sleep_amount // end of CSS sleep
        CSS = [CSS_start, CSS_end];
    }

    // find minimal nap sleep
    sleep_pattern = [Double](repeating:0.0, count: work_offset-CSS_end+1);
    print(work_offset, CSS)
    var y_temp = pcr_simulation(V0: V_tmp, sleep_pattern: sleep_pattern, step: step)

    var H1, H2, C1, C2, D_up1, D_up2: Double
    H1 = y_temp[work_onset-CSS_end][3] // sleep pressure start
    H2 = y_temp[work_offset-CSS_end][3] // sleep pressure end
    C1 = (3.37*0.5)*(1.0 + coef_y*y_temp[work_onset-CSS_end][1] + coef_x*y_temp[work_onset-CSS_end][0])
    C2 = (3.37*0.5)*(1.0 + coef_y*y_temp[work_offset-CSS_end][1] + coef_x*y_temp[work_offset-CSS_end][0])
    D_up1 = (2.46 + 10.2 + C1)/v_vh // sleep threshold start
    D_up2 = (2.46 + 10.2 + C2)/v_vh // sleep threshold start

    if D_up1 + D_up2 - H1 - H2 > 0{ //AL condition is satisfied
        return (CSS, Nap)
    }

    i = 1
    var y_temp2: [[Double]]
    repeat{ // simulate repeatedly increasing nap duration
        if CSS_end >= (work_onset - (i+1)*unit){ // AL condition is not satisfied even we take full sleep
            CSS = [sleep_onset, work_onset - unit]
            return (CSS, Nap)
        }
        
        V_tmp = y_temp[work_onset - (i+1)*unit - CSS_end]
        sleep_pattern = [Double](repeating:0.0, count: work_offset - work_onset + (i+1)*unit + 1)
        for j in 0...i*unit{
            sleep_pattern[j] = 1 // simulate increasing nap as 30 min
        }
        y_temp2 = pcr_simulation(V0: V_tmp, sleep_pattern: sleep_pattern, step:step); // simulate from the end of CSS sleep to the end of work with nap
        H1 = y_temp2[(i+1)*unit][3] // sleep pressure start
        H2 = y_temp2[work_offset - work_onset + (i+1)*unit][3] // sleep pressure end
        C1 = (3.37*0.5)*(1.0 + coef_y*y_temp2[(i+1)*unit][1] + coef_x*y_temp2[(i+1)*unit][0])
        C2 = (3.37*0.5)*(1.0 + coef_y*y_temp2[work_offset - work_onset + (i+1)*unit][1] + coef_x*y_temp2[work_offset - work_onset + (i+1)*unit][0])
        D_up1 = (2.46 + 10.2 + C1)/v_vh // sleep threshold start
        D_up2 = (2.46 + 10.2 + C2)/v_vh // sleep threshold start
        
        if D_up1 + D_up2 - H1 - H2 > 0 { //AL condition is satisfied
            break
        }
        i = i + 1
    } while (true)
    Nap = [work_onset - (i+1)*unit, work_onset - unit] // just in case of numerical error, add 30 min sleep
    return (CSS, Nap)
}


// TEST
func init_data()->[[Double]]{
    let V0 =  [-0.8590, -0.6837, 0.1140, 14.2133] //initial condition
    var sleep_pattern = [Double](repeating: 0.0, count: 12*24*3)
    for i in 1...3 { //sleep from 1h to 7h for every day
        for j in (288*(i-1)+1*12)...(288*(i-1)+7*12) {
            sleep_pattern[j] = 1.0
        }
    }
    
    let y = pcr_simulation(V0: V0, sleep_pattern: sleep_pattern, step: 5/60.0) // run the simulation
    return y
}


// test case
//let current_time = 19*12 // day1 7 pmm
//let sleep_onset = 25*12 // day2 1 am
//let work_onset = 47*12 // day2 11 pm
//let work_offset = 55*12 // day3 7 am
//
//let V0 = [-0.8283,0.8413,0.6758,13.3336]; // test initial condition
//let step = 1/12.0
//var A = Sleep_pattern_suggestion(V0: V0, sleep_onset: sleep_onset - current_time, work_onset: work_onset-current_time, work_offset: work_offset - current_time, step: 1/12.0) // find sleep pattern
//
//print(A)
//
//var sleep_pattern = [Double](repeating: 0.0, count: work_offset-current_time + 1)
//for j in (A.CSS[0])...A.CSS[1]{
//    sleep_pattern[j] = 1
//}
//for j in (A.Nap[0])...(A.Nap[1]){
//    sleep_pattern[j] = 1
//}
//print(sleep_pattern)
//
//let y = pcr_simulation(V0:V0, sleep_pattern: sleep_pattern, step: 1/12.0)
//var H1, H2, C1, C2, D_up1, D_up2: Double
//H1 = y[work_onset-current_time][3] // sleep pressure start
//H2 = y[work_offset-current_time][3] // sleep pressure end
//C1 = (3.37*0.5)*(1.0 + coef_y*y[work_onset-current_time][1] + coef_x*y[work_onset-current_time][0])
//C2 = (3.37*0.5)*(1.0 + coef_y*y[work_offset-current_time][1] + coef_x*y[work_offset-current_time][0])
//D_up1 = (2.46 + 10.2 + C1)/v_vh // sleep threshold start
//D_up2 = (2.46 + 10.2 + C2)/v_vh // sleep threshold start
//
//print(D_up1 + D_up2 - H1 - H2)
//print(y.count)
//print(sleep_pattern.count)


