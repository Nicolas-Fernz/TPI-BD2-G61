<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="GimnasioWeb._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        <div class="row mb-4">
            <div class="col-12">
                <h1 class="h3 mb-1">Panel de gestión del gimnasio</h1>
                <p class="text-muted mb-0">
                    Consultá socios y membresías, y registrá nuevas facturas.
                </p>
            </div>
        </div>

        <div class="row">
            <!-- Socios y membresías -->
            <div class="col-lg-8">
                <div class="card mb-4 shadow-sm">
                    <div class="card-header">
                        <strong>Socios y membresías</strong>
                    </div>
                    <div class="card-body">

                        <div class="row g-3 align-items-end mb-3">
                            <div class="col-md-5">
                                <label class="form-label">Plan de membresía</label>
                                <asp:DropDownList ID="ddlPlanes" runat="server"
                                    CssClass="form-select" />
                            </div>

                            <div class="col-md-4">
                                <div class="form-check mt-4">
                                    <asp:CheckBox ID="chkSoloActivos" runat="server"
                                        CssClass="form-check-input"
                                        Checked="true" />
                                    <label class="form-check-label" for="chkSoloActivos">
                                        Solo membresías activas
                                    </label>
                                </div>
                            </div>

                            <div class="col-md-3 text-md-end">
                                <asp:Button ID="btnFiltrar" runat="server"
                                    Text="Aplicar filtros"
                                    CssClass="btn btn-primary w-100"
                                    OnClick="btnFiltrar_Click" />
                            </div>
                        </div>

                        <div class="table-responsive">
                            <asp:GridView ID="gvSocios" runat="server"
                                AutoGenerateColumns="true"
                                CssClass="table table-striped table-bordered table-sm"
                                HeaderStyle-CssClass="table-dark"
                                EmptyDataText="No se encontraron socios con los filtros seleccionados.">
                            </asp:GridView>
                        </div>

                    </div>
                </div>
            </div>

            <!-- Alta de factura -->
            <div class="col-lg-4">
                <div class="card mb-4 shadow-sm">
                    <div class="card-header">
                        <strong>Registrar nueva factura</strong>
                    </div>
                    <div class="card-body">

                        <div class="mb-3">
                            <label for="txtIdSocio" class="form-label">ID de socio</label>
                            <asp:TextBox ID="txtIdSocio" runat="server"
                                CssClass="form-control" />
                        </div>

                        <div class="mb-3">
                            <label for="txtImporte" class="form-label">Importe</label>
                            <asp:TextBox ID="txtImporte" runat="server"
                                CssClass="form-control" />
                        </div>

                        <div class="mb-3">
                            <label for="txtTipo" class="form-label">Tipo de comprobante</label>
                            <asp:TextBox ID="txtTipo" runat="server"
                                CssClass="form-control" Text="Factura B" />
                        </div>

                        <div class="mb-3">
                            <label for="txtDesc" class="form-label">Descripción</label>
                            <asp:TextBox ID="txtDesc" runat="server"
                                CssClass="form-control" TextMode="MultiLine"
                                Rows="3" />
                        </div>

                        <asp:Button ID="btnFactura" runat="server"
                            Text="Crear factura"
                            CssClass="btn btn-success w-100 mb-2"
                            OnClick="btnFactura_Click" />

                        <asp:Label ID="lblResultado" runat="server"
                            CssClass="d-block mt-2 small"></asp:Label>

                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
