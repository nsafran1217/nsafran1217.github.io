<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/page">
        <html>
            <head>
                <title><xsl:value-of select="title"/></title>
                
                <link rel="stylesheet" href="/css/main.css"/>
                <xsl:if test="@theme='default'">
                    <link rel="stylesheet" href="/css/default-back.css"/>
                </xsl:if>
                <xsl:if test="@theme='dec'">
                    <link rel="stylesheet" href="/css/dec-back.css"/>
                </xsl:if>
                <xsl:if test="@theme='hp'">
                    <link rel="stylesheet" href="/css/hp-back.css"/>
                </xsl:if>
                <xsl:if test="@theme='sgi'">
                    <link rel="stylesheet" href="/css/sgi-back.css"/>
                </xsl:if>
                <xsl:if test="@theme='sun'">
                    <link rel="stylesheet" href="/css/sun-back.css"/>
                </xsl:if>
                <xsl:if test="@theme='ibm'">
                <link rel="stylesheet" href="/css/ibm-back.css"/>
                </xsl:if>

            </head>
            <body>
                <table class="main-body-table">
                    <tbody>
                        <tr>
                            <td class="navbar">
                                <div class="navbar">
                                    <xsl:apply-templates select="document('./nav.xml')/navigation"/>
                                </div>
                            </td>
                            <td class="main-body-td">
                                <xsl:for-each select="sections/section">
                                    <div class="main-body-container">
                                        <div class="window-title"><xsl:value-of select="window-title"/></div>
                                        <div class="main-body">
                                            <xsl:copy-of select="content"/>
                                        </div>
                                    </div>
                                </xsl:for-each>
                            </td>
                            <td class="td-spacer"></td>
                        </tr>
                    </tbody>
                </table>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="navigation">
        <div class="window-title">Navigation</div>
        <div class="cde-menu">
            <xsl:copy-of select="content"/>
        </div>
    </xsl:template>
</xsl:stylesheet>
