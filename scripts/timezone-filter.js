// scripts/timezone-filter.js
// Hexo 时区处理过滤器

const moment = require('moment-timezone');

// 注册模板局部变量过滤器
hexo.extend.filter.register('template_locals', function(locals) {
  
  // 处理页面数据
  if (locals.page) {
    // 处理最后更新时间
    if (locals.page.last_updated) {
      try {
        // 将存储的时间转换为中国时区显示
        const chinaTime = moment(locals.page.last_updated).tz('Asia/Shanghai');
        
        // 添加格式化后的显示时间（多种格式备用）
        locals.page.last_updated_display = chinaTime.format('YYYY-MM-DD HH:mm:ss');
        locals.page.last_updated_iso = chinaTime.format();
        locals.page.last_updated_readable = chinaTime.format('YYYY年MM月DD日 HH:mm:ss');
        
        // 调试信息（仅在开发模式显示）
        if (hexo.env.debug) {
          console.log(`时区转换: ${locals.page.last_updated} -> ${locals.page.last_updated_display}`);
        }
      } catch (error) {
        console.error('时间转换错误:', error);
        // 如果转换失败，使用原始时间
        locals.page.last_updated_display = locals.page.last_updated;
      }
    }
    
    // 同样处理创建时间
    if (locals.page.date) {
      try {
        const chinaDate = moment(locals.page.date).tz('Asia/Shanghai');
        locals.page.date_display = chinaDate.format('YYYY-MM-DD HH:mm:ss');
        locals.page.date_readable = chinaDate.format('YYYY年MM月DD日 HH:mm:ss');
      } catch (error) {
        console.error('创建时间转换错误:', error);
        locals.page.date_display = locals.page.date;
      }
    }
  }
  
  // 处理文章列表（归档页、首页等）
  if (locals.posts) {
    locals.posts.data.forEach(post => {
      if (post.last_updated) {
        try {
          const chinaTime = moment(post.last_updated).tz('Asia/Shanghai');
          post.last_updated_display = chinaTime.format('YYYY-MM-DD HH:mm:ss');
        } catch (error) {
          post.last_updated_display = post.last_updated;
        }
      }
      
      if (post.date) {
        try {
          const chinaDate = moment(post.date).tz('Asia/Shanghai');
          post.date_display = chinaDate.format('YYYY-MM-DD HH:mm:ss');
        } catch (error) {
          post.date_display = post.date;
        }
      }
    });
  }
  
  // 为整个站点添加时区信息
  locals.site_timezone = 'Asia/Shanghai';
  locals.site_timezone_offset = '+08:00';
  
  return locals;
});

// 注册另一个过滤器，确保在生成前后都能处理
hexo.extend.filter.register('after_post_render', function(data) {
  if (data.last_updated) {
    try {
      const chinaTime = moment(data.last_updated).tz('Asia/Shanghai');
      data.last_updated_display = chinaTime.format('YYYY-MM-DD HH:mm:ss');
    } catch (error) {
      data.last_updated_display = data.last_updated;
    }
  }
  return data;
});