using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;

namespace GimnasioWeb
{
    public partial class _Default : Page
    {   private string ConnStr =>
        ConfigurationManager.ConnectionStrings["GimnasioDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e) //
        {
        if (!IsPostBack)
            {   CargarPlanes();
                CargarSociosDetalle();
            }
        }
        private void CargarPlanes()
        {
        using (var con = new SqlConnection(ConnStr))
        using (var cmd = new SqlCommand("SELECT Id, Nombre FROM PlanMembresia", con))
            {
             con.Open();
             ddlPlanes.DataSource = cmd.ExecuteReader();
             ddlPlanes.DataTextField = "Nombre";
             ddlPlanes.DataValueField = "Id";
             ddlPlanes.DataBind();
             ddlPlanes.Items.Insert(0,
             new System.Web.UI.WebControls.ListItem("--Todos--", ""));
            }
        }

        private void CargarSociosDetalle(int? idPlan = null, bool soloActivos = true)
        {
        using (var con = new SqlConnection(ConnStr))
        using (var cmd = new SqlCommand("sp_ReporteSociosPorPlan", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@IdPlanMembresia",
                    (object)idPlan ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@BuscarSoloActivos",
                    soloActivos ? 1 : 0);

                con.Open();
                using (var da = new SqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    da.Fill(dt);
                    gvSocios.DataSource = dt;
                    gvSocios.DataBind();
                }
            }
        }

        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            int? idPlan = null;
            if (!string.IsNullOrEmpty(ddlPlanes.SelectedValue))
                idPlan = int.Parse(ddlPlanes.SelectedValue);

            CargarSociosDetalle(idPlan, chkSoloActivos.Checked);
            lblResultado.Text = string.Empty;
        }

        protected void btnFactura_Click(object sender, EventArgs e)
        {
            try
            {
                int idSocio = int.Parse(txtIdSocio.Text.Trim());
                decimal importe = decimal.Parse(txtImporte.Text.Trim());
                string tipo = txtTipo.Text.Trim();
                string desc = txtDesc.Text.Trim();

                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("sp_RegistrarFactura", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdSocio", idSocio);
                    cmd.Parameters.AddWithValue("@Importe", importe);
                    cmd.Parameters.AddWithValue("@TipoFactu", tipo);
                    cmd.Parameters.AddWithValue("@Descrip",
                        string.IsNullOrWhiteSpace(desc)
                            ? (object)DBNull.Value
                            : desc);

                    con.Open();

                    // El SP crea la factura siempre con Pagado = 0
                    var idFacturaObj = cmd.ExecuteScalar();
                    int idFactura = Convert.ToInt32(idFacturaObj);

                    // Si el usuario tildó el check, la marcamos como pagada
                    if (chkMarcarPagada.Checked)
                    {
                        using (var cmdPago = new SqlCommand(
                            "UPDATE Factura SET Pagado = 1 WHERE Id = @id", con))
                        {
                            cmdPago.Parameters.AddWithValue("@id", idFactura);
                            cmdPago.ExecuteNonQuery();
                        }

                        lblResultado.ForeColor = System.Drawing.Color.Green;
                        lblResultado.Text =
                            "Factura creada y marcada como PAGADA. Id = " + idFactura;
                    }
                    else
                    {
                        lblResultado.ForeColor = System.Drawing.Color.Green;
                        lblResultado.Text =
                            "Factura creada como NO pagada (pendiente). Id = " + idFactura;
                    }
                }
            }
            catch (Exception ex)
            {
                lblResultado.ForeColor = System.Drawing.Color.Red;
                lblResultado.Text =
                    "Error al crear la factura: " + ex.Message;
            }
        }
    
    }
}