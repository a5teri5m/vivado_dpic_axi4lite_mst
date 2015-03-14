`timescale 1ns/1ps
`default_nettype none
module test;

    reg          axi_aclk, axi_aresetn;

    wire [31:0]  axi_awaddr; 
    wire [2:0]   axi_awprot; 
    wire         axi_awvalid;
    wire         axi_awready;
    wire [31:0]  axi_wdata;  
    wire [3:0]   axi_wstrb;  
    wire         axi_wvalid; 
    wire         axi_wready; 
    wire [1:0]   axi_bresp;  
    wire         axi_bvalid; 
    wire         axi_bready;
    wire [31:0]  axi_araddr;
    wire [2:0]   axi_arprot;
    wire         axi_arvalid;
    wire         axi_arready;
    wire [31:0]  axi_rdata;
    wire [1:0]   axi_rresp;
    wire         axi_rvalid;
    wire         axi_rready;

    reg          run;
    wire         finish, error;


	
    initial begin
        forever begin
            axi_aclk = 1'b0;
            #(2.5) axi_aclk = 1'b1;
            #(2.5);
        end
    end


    initial begin
        axi_aresetn <= 1'b0;
        run <= 1'b0;
        #50;
        axi_aresetn <= 1'b1;
        #50;
        run <= 1'b1;
        wait(finish == 1'b1);
        #100;
        $finish;
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(2);
    end


    axi4l_mst # (
        .INST_NAME("MST")
    ) MST (
        .axi_aclk(axi_aclk),
        .axi_aresetn(axi_aresetn),
        .m_axi_awaddr(axi_awaddr),
        .m_axi_awprot(axi_awprot),
        .m_axi_awvalid(axi_awvalid),
        .m_axi_awready(axi_awready),
        .m_axi_wdata(axi_wdata),
        .m_axi_wstrb(axi_wstrb),
        .m_axi_wvalid(axi_wvalid),
        .m_axi_wready(axi_wready),
        .m_axi_bresp(axi_bresp),
        .m_axi_bvalid(axi_bvalid),
        .m_axi_bready(axi_bready),
        .m_axi_araddr(axi_araddr),
        .m_axi_arprot(axi_arprot),
        .m_axi_arvalid(axi_arvalid),
        .m_axi_arready(axi_arready),
        .m_axi_rdata(axi_rdata),
        .m_axi_rresp(axi_rresp),
        .m_axi_rvalid(axi_rvalid),
        .m_axi_rready(axi_rready),

        .run(run),
        .finish(finish),
        .error(error)
    );




    axi4l_slv # (
        .INST_NAME("SLV")
    ) SLV (
        .axi_aclk(axi_aclk),
        .axi_aresetn(axi_aresetn),

        .s_axi_awaddr(axi_awaddr), 
        .s_axi_awprot(axi_awprot), 
        .s_axi_awvalid(axi_awvalid),
        .s_axi_awready(axi_awready),
        .s_axi_wdata(axi_wdata),  
        .s_axi_wstrb(axi_wstrb),  
        .s_axi_wvalid(axi_wvalid), 
        .s_axi_wready(axi_wready), 
        .s_axi_bresp(axi_bresp),  
        .s_axi_bvalid(axi_bvalid), 
        .s_axi_bready(axi_bready),
        .s_axi_araddr(axi_araddr),
        .s_axi_arprot(axi_arprot),
        .s_axi_arvalid(axi_arvalid),
        .s_axi_arready(axi_arready),
        .s_axi_rdata(axi_rdata),
        .s_axi_rresp(axi_rresp),
        .s_axi_rvalid(axi_rvalid),
        .s_axi_rready(axi_rready)
    );



endmodule
`default_nettype wire

