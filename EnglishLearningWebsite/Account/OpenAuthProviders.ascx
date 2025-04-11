<%@ Control Language="C#" AutoEventWireup="true" CodeFile="OpenAuthProviders.ascx.cs" Inherits="OpenAuthProviders" %>

<div id="socialLoginList">
    <h4>使用其他服務進行登入。</h4>
    <hr />
    <asp:ListView runat="server" ID="providerDetails" ItemType="System.String"
        SelectMethod="GetProviderNames" ViewStateMode="Disabled">
        <ItemTemplate>
            <p>
                <button type="submit" class="btn btn-default" name="provider" value="<%#: Item %>"
                    title="使用您的帳戶<%#: Item %>登入。">
                    <%#: Item %>
                </button>
            </p>
        </ItemTemplate>
        <EmptyDataTemplate>
            <div>
                <p>未設定任何外部驗證服務。如需設定此 ASP.NET 應用程式以支援透過外部服務登入的詳細資料，請參閱<a href="https://go.microsoft.com/fwlink/?LinkId=252803">此文章</a>。</p>
            </div>
        </EmptyDataTemplate>
    </asp:ListView>
</div>