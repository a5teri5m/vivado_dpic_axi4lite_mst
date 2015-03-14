
`default_nettype none
module axi4l_mst # (
    parameter INST_NAME = "u_axi4l_mst"
) (
    input  wire         axi_aclk,
    input  wire         axi_aresetn,
    output reg  [31:0]  m_axi_awaddr,
    output wire [2:0]   m_axi_awprot,
    output reg          m_axi_awvalid,
    input  wire         m_axi_awready,
    output reg  [31:0]  m_axi_wdata,
    output wire [3:0]   m_axi_wstrb,
    output reg          m_axi_wvalid,
    input  wire         m_axi_wready,
    input  wire [1:0]   m_axi_bresp,
    input  wire         m_axi_bvalid,
    output reg          m_axi_bready,
    output reg  [31:0]  m_axi_araddr,
    output wire [2:0]   m_axi_arprot,
    output reg          m_axi_arvalid,
    input  wire         m_axi_arready,
    input  wire [31:0]  m_axi_rdata,
    input  wire [1:0]   m_axi_rresp,
    input  wire         m_axi_rvalid,
    output reg          m_axi_rready,

    input  wire         run,
    output reg          finish,
    output reg  [31:0]  trans_idx,
    output reg          error
);

    typedef enum reg [2:0] {
        ST_IDLE,
        ST_OPEN_SCN,
        ST_READ_SCN,
        ST_TRANS_WR,
        ST_TRANS_WR_WAIT,
        ST_TRANS_RD,
        ST_TRANS_RD_WAIT,
        ST_FINISH
    } state_t;
    state_t state;


	wire  	error_wr_resp, error_rd_resp;
	reg  	trans_wr;
	reg  	trans_rd;
	reg  	run_d1, run_d2, run_pulse;
    reg  [31:0]   mst_awaddr, mst_wdata, mst_araddr;

	integer ret, delay, mode, addr, data;
    time    trans_start;

    import "DPI-C" pure function int open_scn();
    import "DPI-C" pure function int read_scn(
        output int delay, output int mode, 
        output int addr, output int data);
    import "DPI-C" pure function int close_scn();
	
    assign m_axi_awprot	= 3'b000;
	assign m_axi_wstrb	= 4'b1111;
	assign m_axi_arprot	= 3'b001;
	assign run_pulse = (~run_d2) & run_d1;


	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 1'b0 ) begin
	        run_d1 <= 1'b0;
	        run_d2 <= 1'b0;
	    end else begin
	        run_d1 <= run;
	        run_d2 <= run_d1;
	    end
	end


    // awvalid
    always @(posedge axi_aclk) begin
	    if (axi_aresetn == 0 || run_pulse == 1'b1) begin
	        m_axi_awvalid <= 1'b0;
	    end else begin
	        if (trans_wr) begin
	            m_axi_awvalid <= 1'b1;
	        end else if (m_axi_awready && m_axi_awvalid) begin
	            m_axi_awvalid <= 1'b0;
	        end
	    end
	end
	

    // wvalid
	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 0 || run_pulse == 1'b1) begin
	        m_axi_wvalid <= 1'b0;
	    end else if (trans_wr) begin
	        m_axi_wvalid <= 1'b1;
	    end else if (m_axi_wready && m_axi_wvalid) begin
	        m_axi_wvalid <= 1'b0;
	    end
	end

	// bready
    always @(posedge axi_aclk) begin
	    if (axi_aresetn == 0 || run_pulse == 1'b1) begin
	        m_axi_bready <= 1'b0;
	    end else if (m_axi_bvalid && ~m_axi_bready) begin
	        m_axi_bready <= 1'b1;
	    end else if (m_axi_bready) begin
	        m_axi_bready <= 1'b0;
	    end else begin
	        m_axi_bready <= m_axi_bready;
        end
	end

    
    // arvalid
    always @(posedge axi_aclk) begin
	    if (axi_aresetn == 0 || run_pulse == 1'b1) begin
	        m_axi_arvalid <= 1'b0;
	    end else if (trans_rd) begin
	        m_axi_arvalid <= 1'b1;
	    end else if (m_axi_arready && m_axi_arvalid) begin
	        m_axi_arvalid <= 1'b0;
	    end
	end

    
    // rready
	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 0 || run_pulse == 1'b1) begin
	        m_axi_rready <= 1'b0;
	    end else if (m_axi_rvalid && ~m_axi_rready) begin
	        m_axi_rready <= 1'b1;
	    end else if (m_axi_rready) begin
	        m_axi_rready <= 1'b0;
	    end
	end


	// awaddr
    always @(posedge axi_aclk) begin
	    if (axi_aresetn == 0  || run_pulse == 1'b1) begin
	        m_axi_awaddr <= 32'b0;
	    //end else if (m_axi_awready && m_axi_awvalid) begin
	    end else if (state == ST_TRANS_WR) begin
	        m_axi_awaddr <= mst_awaddr;
	    end
	end
	
	// wdata  
    always @(posedge axi_aclk) begin
	    if (axi_aresetn == 0 || run_pulse == 1'b1 ) begin
	        m_axi_wdata <= 32'b0;
	    //end else if (m_axi_wready && m_axi_wvalid) begin
	    end else if (state == ST_TRANS_WR) begin
	        m_axi_wdata <= mst_wdata;
	    end
	end          	
	
	// araddr
	always @(posedge axi_aclk) begin
	    if (axi_aresetn == 0 || run_pulse == 1'b1) begin
	        m_axi_araddr <= 32'b0;
	    //end else if (m_axi_arready && m_axi_arvalid) begin
	    end else if (state == ST_TRANS_RD) begin
	        m_axi_araddr <= mst_araddr;
	    end
	end

    // main state
    always @(posedge axi_aclk) begin
        if (axi_aresetn == 1'b0) begin
            state <= ST_IDLE;
            trans_wr <= 1'b0;
            trans_rd <= 1'b0;
            error   <= 1'b0;
            finish <= 1'b0;
            mst_awaddr <= 32'b0;
            mst_wdata <= 32'b0;
            mst_araddr <= 32'b0;
            trans_idx <= 32'b0;            
        end else begin
            case (state)
            ST_IDLE: begin
                state <= ST_IDLE;
                trans_wr <= 1'b0;
                trans_rd <= 1'b0;
                error   <= 1'b0;
                finish <= 1'b0;
                mst_awaddr <= 32'b0;
                mst_wdata <= 32'b0;
                mst_araddr <= 32'b0;
                trans_idx <= 32'b0;            
                if (run_pulse == 1'b1) begin
                    state <= ST_OPEN_SCN;
                end
            end
            ST_OPEN_SCN: begin
                state <= ST_READ_SCN;
                ret = open_scn();
                if (ret != 0) begin
                    $finish;
                end
            end
            ST_READ_SCN: begin
                ret = read_scn(delay, mode, addr, data);
                if (ret == 0) begin
                    trans_idx <= trans_idx + 1'b1;            
                    trans_start <= $time + delay;
                    if (mode == 0) begin
                        state <= ST_TRANS_RD;
                        mst_araddr <= addr;
                    end else begin
                        state <= ST_TRANS_WR;
                        mst_awaddr <= addr;
                        mst_wdata <= data;
                    end
                end else if (ret == 3) begin
                    state <= ST_FINISH;
                    finish <= 1'b1;
                end else begin
                    state <= ST_FINISH;
                    finish <= 1'b1;
                    error <= 1'b1;
                end
            end
            ST_TRANS_WR: begin
                if ($time >= trans_start) begin
                    state <= ST_TRANS_WR_WAIT;
                    trans_wr <= 1'b1;
                    $strobe("%t: [%s] WR ( ADDR=%H, DATA=%H )", $time, INST_NAME, m_axi_awaddr, m_axi_wdata);
                end
            end
            ST_TRANS_WR_WAIT: begin
                trans_wr <= 1'b0;
                if (m_axi_bvalid && m_axi_bready) begin
                    state <= ST_READ_SCN;
                    error <= m_axi_bresp[1];
                end
            end
            ST_TRANS_RD: begin
                if ($time >= trans_start) begin
                    state <= ST_TRANS_RD_WAIT;
                    trans_rd <= 1'b1;
                    $strobe("%t: [%s] RD ( ADDR=%H )", $time, INST_NAME, m_axi_araddr);
                end
            end
            ST_TRANS_RD_WAIT: begin
                trans_rd <= 1'b0;
                if (m_axi_rvalid && m_axi_rready) begin
                    state <= ST_READ_SCN;
                    error <= m_axi_rresp[1];
	                $strobe("%t: [%s] RE ( DATA=%H )", $time, INST_NAME, m_axi_rdata);
                end
            end
            ST_FINISH: begin
                state <= ST_IDLE;
                finish <= 1'b0;
                ret = close_scn();
                if (ret != 0) begin
                    $finish;
                end
            end
            default: begin
                state <= ST_IDLE;
                trans_wr <= 1'b0;
                trans_rd <= 1'b0;
                finish <= 1'b0;
                mst_awaddr <= 32'b0;
                mst_wdata <= 32'b0;
                mst_araddr <= 32'b0;
            end
            endcase
        end
    end

endmodule


