# RISC-V CPU BASE
 Description:

    This student project implements the RV-32I instruction set (excluding the FENCE and CSR instructions). 
    It's written in Verilog and SystemVerilog. Verilog for (most) modules and SystemVerilog for testbenches.
    For synthesis I used Quartus and for simulation I used Modelsim. 
    The target board for this project is the DE10-Lite using a MAX10 family FPGA. 

    I created this project as a means for me to:

        Practice Verilog and SystemVerilog

        Improve my understanding of processor microarchitecture and operation

        Gain further experience using EDA tools such as Quartus and Modelsim 

        Learn the RISC-V ISA

        Create a base design that I can modify and build upon

How to Install and Run (Quartus):

    1. Clone the repository.

    2. Create a new project.

    3. Select everything in the RISC_V_Processor_V0 folder as the project contents.

    4. Select RISC_V_Processor_V0.sv as the top level module.

    5. Designate all files within the Testbenches folder as testbenches used for simulation. 

    6. Create a RAM unit matching the settings listed in ramOnePort.txt and name the module ramOnePort.

    7. Synthesize the project.

    8. Simulate the project using one of the sample testbenches given or one of your own.

How to use this project:

    Again, this project is intended as a base to be modified and built upon.
    Some examples on how this project may be used are:

        Implementing the classic RISC pipeline

        Implementing Multilevel Caching

        Building MMIO or PMIO

        Optimizing this design for a given metric (power consumption, die size, ICR, IPC, ect...)

        Creating a new RISC-V ISA extension with implementation

How to Contribute:
    Feel free to fork this project and make a pull request with your changes.

Credits:
    Marshall Knowles
    https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf