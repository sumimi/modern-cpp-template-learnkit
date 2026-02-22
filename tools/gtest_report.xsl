<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" indent="yes" encoding="UTF-8"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>Google Test Results</title>
        <style type="text/css">
          body {
            font:normal 68% verdana,arial,helvetica;
            color:#000000;
          }
          table tr td, table tr th {
              font-size: 68%;
          }
          table.details tr th{
            font-weight: bold;
            text-align:left;
            background:#a6caf0;
          }
          table.details tr td{
            background:#eeeee0;
          }
          h1 {
            margin: 0px 0px 5px; font: 165% verdana,arial,helvetica
          }
          h2 {
            margin-top: 1em; margin-bottom: 0.5em; font: bold 125% verdana,arial,helvetica
          }
          .success {
            background-color: #e6ffe6;
          }
          .failure {
            background-color: #ffe6e6;
          }
          .error {
            background-color: #fff0e6;
          }
          .bar-container {
            width: 300px;
            max-width: 100%;
            background-color: #f1f1f1;
            border: 1px solid #ccc;
            margin-top: 5px;
            margin-bottom: 10px;
          }
          .bar-fill {
            height: 16px;
            text-align: right;
            padding-right: 5px;
            color: white;
            font-weight: bold;
            white-space: nowrap;
          }
          .bar-success { background-color: #4CAF50; }
          .bar-failure { background-color: #f44336; }
        </style>
      </head>
      <body>
        <a name="top"></a>
        <h1>Google Test Report</h1>
        <xsl:apply-templates select="testsuites"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="testsuites">
    <xsl:variable name="total" select="number(@tests)"/>
    <xsl:variable name="failures" select="number(@failures)"/>
    <xsl:variable name="errors" select="number(@errors)"/>
    <xsl:variable name="success" select="$total - $failures - $errors"/>
    <xsl:variable name="successRate" select="round(100 * $success div $total)"/>
    <xsl:variable name="failRate" select="round(100 * ($failures + $errors) div $total)"/>

    <h2>Summary</h2>
    <table class="details" border="0" cellpadding="5" cellspacing="2" width="95%">
      <tr>
        <th>Total Tests</th>
        <th>Success</th>
        <th>Failures</th>
        <th>Errors</th>
        <th>Time (s)</th>
        <th>Success Rate</th>
        <th>Failure Rate</th>
      </tr>
      <tr>
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="$failures &gt; 0">failure</xsl:when>
            <xsl:when test="$errors &gt; 0">error</xsl:when>
            <xsl:otherwise>success</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <td><xsl:value-of select="$total"/></td>
        <td><xsl:value-of select="$success"/></td>
        <td><xsl:value-of select="$failures"/></td>
        <td><xsl:value-of select="$errors"/></td>
        <td><xsl:value-of select="@time"/></td>
        <td>
          <xsl:value-of select="$successRate"/>%
          <div class="bar-container">
            <div class="bar-fill bar-success">
              <xsl:attribute name="style">width:<xsl:value-of select="$successRate"/>%</xsl:attribute>
              <xsl:value-of select="$successRate"/>%
            </div>
          </div>
        </td>
        <td>
          <xsl:value-of select="$failRate"/>%
          <div class="bar-container">
            <xsl:choose>
              <xsl:when test="$failRate = 0">
                <div class="bar-fill bar-failure" style="display:none;"></div>
              </xsl:when>
              <xsl:otherwise>
                <div class="bar-fill bar-failure">
                  <xsl:attribute name="style">width:<xsl:value-of select="$failRate"/>%</xsl:attribute>
                  <xsl:value-of select="$failRate"/>%
                </div>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </td>
      </tr>
    </table>
    <xsl:apply-templates select="testsuite"/>
  </xsl:template>

  <xsl:template match="testsuite">
    <xsl:variable name="total" select="number(@tests)"/>
    <xsl:variable name="failures" select="number(@failures)"/>
    <xsl:variable name="errors" select="number(@errors)"/>
    <xsl:variable name="success" select="$total - $failures - $errors"/>
    <xsl:variable name="successRate" select="round(100 * $success div $total)"/>

    <h2>Test Suite: <xsl:value-of select="@name"/></h2>
    <p>Success Rate: <xsl:value-of select="$successRate"/>%</p>
    <div class="bar-container">
      <div class="bar-fill bar-success">
        <xsl:attribute name="style">width:<xsl:value-of select="$successRate"/>%</xsl:attribute>
        <xsl:value-of select="$successRate"/>%
      </div>
    </div>
    <table class="details" border="0" cellpadding="5" cellspacing="2" width="95%">
      <tr>
        <th>Test Case</th>
        <th>Status</th>
        <th>Time (s)</th>
      </tr>
      <xsl:apply-templates select="testcase"/>
    </table>
  </xsl:template>

  <xsl:template match="testcase">
    <tr>
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="failure">failure</xsl:when>
          <xsl:when test="error">error</xsl:when>
          <xsl:otherwise>success</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <td><xsl:value-of select="@name"/></td>
      <td>
        <xsl:choose>
          <xsl:when test="failure">Failure</xsl:when>
          <xsl:when test="error">Error</xsl:when>
          <xsl:otherwise>Success</xsl:otherwise>
        </xsl:choose>
      </td>
      <td><xsl:value-of select="@time"/></td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
