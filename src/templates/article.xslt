<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8"/>
    <xsl:template match="/page">
        <!-- Standards mode in modern browsers; very old browsers ignore it -->
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#10;</xsl:text>
        <html lang="en">
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
                                <!--
                                    Each window is three one-row tables (top / middle / bottom),
                                    with exactly one background image per cell. This avoids CSS
                                    multiple backgrounds so the frame renders in old browsers.
                                    Rows are separate tables because the corner pieces are wider
                                    than the side edges (e.g. 150px title-bar corner vs 25px edge).
                                -->
                                <xsl:for-each select="sections/section">
                                    <div class="main-body-container">
                                        <div class="window-title"><xsl:value-of select="window-title"/></div>
                                        <table class="win-row" cellspacing="0" cellpadding="0" border="0" width="100%">
                                            <tr>
                                                <td class="win-tl">&#160;</td>
                                                <td class="win-t">&#160;</td>
                                                <td class="win-tr">&#160;</td>
                                            </tr>
                                        </table>
                                        <table class="win-row" cellspacing="0" cellpadding="0" border="0" width="100%">
                                            <tr>
                                                <td class="win-l">&#160;</td>
                                                <td class="win-body">
                                                    <div class="main-body">
                                                        <!-- content/node(): copy what's inside <content>, not the wrapper itself -->
                                                        <xsl:copy-of select="content/node()"/>
                                                    </div>
                                                </td>
                                                <td class="win-r">&#160;</td>
                                            </tr>
                                        </table>
                                        <table class="win-row" cellspacing="0" cellpadding="0" border="0" width="100%">
                                            <tr>
                                                <td class="win-bl">&#160;</td>
                                                <td class="win-b">&#160;</td>
                                                <td class="win-br">&#160;</td>
                                            </tr>
                                        </table>
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
    
    <!-- Nav panel: top / middle / bottom blocks, one background image each -->
    <xsl:template match="navigation">
        <div class="window-title">Navigation</div>
        <div class="nav-top">&#160;</div>
        <div class="nav-mid">
            <div class="cde-menu">
                <xsl:copy-of select="content/node()"/>
            </div>
        </div>
        <div class="nav-bot">&#160;</div>
    </xsl:template>
</xsl:stylesheet>
